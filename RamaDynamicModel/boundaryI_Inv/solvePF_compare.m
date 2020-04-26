% run boundary I inv + 5-bus network DAE simulation:
% --------------------------------------------
clc; clear all; close all;

caseName='case5';
c = loadcase(caseName);
N = size(c.bus,1);
invBus=4; % user choose 

% after calling, workspace will have "inverter_params" and x0 vars
Ts=0.1; % if choose too large you wont see delay constants effecting, if choose too fast not realistic sample time

%% Create meas from trace    
% create 2N nonlin algebriac equations, where n is number of nodes; each node has 2 unknowns
% Slack bus: know [V del], dont know [P Q]
% Gen bus: know [P V], dont know [del Q]
% Load bus: know [P Q], dont know [V del]

   [M_k,Mbar_k,Y_k,Ybar_k,Y_lm,Ybar_lm,Y_ml,Ybar_ml]=computeYmats(c);
    h_V=@(x,M_k) sqrt(trace(M_k*x*x')); % note Tr(Mk*x*x')=V^2, not V! add sqrt so that dont run into this error
    h_del=@(x,Mbar_k) trace(Mbar_k*x*x'); 
    h_P=@(x,Y_k) trace(Y_k*x*x');
    h_Q=@(x,Ybar_k) -trace(Ybar_k*x*x');
    h_Pline=@(x,Y_lm) trace(Y_lm*x*x'); % can take in l-->m or m-->l Y matrices
    h_Qline=@(x,Ybar_lm) -trace(Ybar_lm*x*x'); % add neg to make sign convention agree with runpf and vYv formulation

vmagVec=c.bus(:,8).*c.bus(:,10) % units=V, pu*base=actual
thetaVec_deg=c.bus(:,9) % units=degrees
thetaVec=thetaVec_deg*(pi/180); % convert to radians

if (c.bus(invBus,2)~=3) % stop code if chosen inv bus is not generator bus type
       error('Error. Inv bus must be a load bus (type 3)');
end

  knowns=cell(1,4); % hold V,del,P,Q to pass into dxdt func
  knowns{1}=c.bus(:,8).*c.bus(:,10); % units=V, pu*base=actual
  thetaVec_deg=c.bus(:,9); % units=degrees
  knowns{2}=thetaVec; % radians
  knowns{3}=c.gen(:,2)-c.bus(:,3); % P
  knowns{4}=c.gen(:,3)-c.bus(:,4); % Q
  knownsBefore=cell2mat(knowns)
  % neg is load/pow demand, pos is generation
  V=knowns{1}; del=knowns{2}; P=knowns{3}; Q=knowns{4};

% use starting voltages to build x0
PFlabel=[];
% state vec x contains unknowns for every bus type
  for k = 1:N % creat 2*N bus equations
            busType=c.bus(k,2);
            switch busType % take different measurements at diff bus types
                case 1 % slack bus
                    x0(2*k-1)=h_P([V; del],Y_k{k}); % P
                    x0(2*k)=h_Q([V; del],Ybar_k{k}); % Q
                    PFlabel=[PFlabel 'P ' 'Q '];
                case 2 % gen bus 
                    x0(2*k-1)=h_del([V; del],Mbar_k{k}); % del
                    x0(2*k)=h_Q([V; del],Ybar_k{k}); % Q
                    PFlabel=[PFlabel 'del ' 'Q '];
                case 3 % load bus
                    x0(2*k-1)=h_V([V; del],M_k{k}); ; % V
                    x0(2*k)=h_del([V; del],Mbar_k{k}); % del
                    if k==invBus
                       vmag_inv=V(k);
                       vang_inv=del(k);
                        Pt0=P(k);
                        Qt0=Q(k);
                    end
                    PFlabel=[PFlabel 'V ' 'del '];
            end
  end

  parameters2 % call the parameters.m to set populate workspace
  % delet off inv states that are set by PF eqns because x0 has PF eqns
  % already
  x0_inv(13:16)=[]; % delete off redundant states
  x0=[x0_inv; x0'; [Pt0 Qt0 vmag_inv vang_inv]'];
  

%%  Run fsolve
x00= fsolve(@(x)boundaryinv_network2(0,x,c,inverter_params,Ts,invBus,knowns),x0);
xdot_init=boundaryinv_network2(0,x00,c,inverter_params,Ts,invBus,knowns); % for debugging: compute xdot at first timestep
nInvState=13; 
stateLabel1=[sprintf('inv%d ', 1:nInvState),PFlabel,'Pt Qt Vterm Vterm_theta']
printmat([x0 x00 xdot_init], 'Init States', stateLabel1,'x0 x00 xdot')

%% Collect solns from fsolve
% input: c, vmagVec, thetaVec, P, Q, x00
% output: vmagVec, thetaVec, P, Q

% when finished, vmagVec, thetaVec, P, Q vectors are Nx1 and have full set
% of knowns and solns (originally unknown)
ofs=nInvState;
    for k = 1:N % creat 2*N bus equations, after this state vector is (ofs+2N)x1
        busType=c.bus(k,2);
        switch busType % take different measurements at diff bus types
            case 1
                knowns{3}(k)=x00(ofs+2*k-1); % P
                knowns{4}(k)=x00(ofs+2*k); % Q
            case 2
                knowns{2}(k)=x00(ofs+2*k-1); % del
                knowns{4}(k)=x00(ofs+2*k); % Q
            case 3
                knowns{1}(k)=x00(ofs+2*k-1); % V
                knowns{2}(k)=x00(ofs+2*k);  % del
        end
    end
knownsFsolve=cell2mat(knowns);

%% Solve DAE
% solve DAE
n=size(x0,1); % tot num states,27
M=zeros(n);
M(1,1)=1; M(2,2)=1; M(3,3)=1; M(4,4)=1; M(7,7)=1; M(8,8)=1; M(9,9)=1; M(10,10)=1; M(13,13)=1;
options = odeset('Mass',M,'RelTol',1e-4,'AbsTol',1e-4);
runItvl=[0 5];
%Sload=[]; % store load changes to plot later

% before step change in load Q
    tspan1 = runItvl(1):Ts:runItvl(2);
    %Sload=[Sload repmat(inverter_params.Sload,1,length(tspan1))];
    [t1,y1] = ode15s(@(t,x)boundaryinv_network2(t,x,c,inverter_params,Ts,invBus,knowns),tspan1,x00,options);

    % see boundaryinv_infBus2 for example of solving DAE with change of params
    t =t1;
    y =y1;  

    
%% Collect solns from ODE15s
% input: c, vmagVec, thetaVec, P, Q,y
% output: vmagVec, thetaVec, P, Q

% when finished, vmagVec, thetaVec, P, Q vectors are Nx1 and have full set
% of knowns and solns (originally unknown)
ofs=nInvState;
    for k = 1:N % creat 2*N bus equations, after this state vector is (ofs+2N)x1
        busType=c.bus(k,2);
        switch busType % take different measurements at diff bus types
            case 1
                knowns{3}(k)=y(ofs+2*k-1); % P
                knowns{4}(k)=y(ofs+2*k); % Q
            case 2
                knowns{2}(k)=y(ofs+2*k-1); % del
                knowns{4}(k)=y(ofs+2*k); % Q
            case 3
                knowns{1}(k)=y(ofs+2*k-1); % V
                knowns{2}(k)=y(ofs+2*k);  % del
        end
    end
    knownsODE15s=cell2mat(knowns);

%% Print known and unknown states  in order 1:N, and create graphs
% graphs show the power network and nodal powers at different times of sim, as well as change in nodal powers    
knownsFsolve=cell2mat(knowns);
printmat(knownsBefore, 'knowns init',sprintf('node%d ', 1:size(knownsBefore,1)),'V del_rad P Q')
printmat(knownsFsolve, 'knowns after fsolve',sprintf('node%d ', 1:size(knownsFsolve,1)),'V del_rad P Q')
printmat(knownsODE15s, 'knowns after solve DAE',sprintf('node%d ', 1:size(knownsFsolve,1)),'V del_rad P Q')
knownChange1=knownsBefore-knownsFsolve;
knownChange2=knownsBefore-knownsODE15s;


    % build edge coordinates
    xcoors=c.branch(:,1); ycoors=c.branch(:,2);
    G=graph(xcoors,ycoors);
    plotPowGraph(G,knownsBefore,strcat('Power network, init nodal pow, ',num2str(caseName)),invBus);
    plotPowGraph(G,knownsFsolve,strcat('Power network, nodal pow after fsolve, ',num2str(caseName)),invBus);
    plotPowGraph(G,knownsODE15s,strcat('Power network, nodal pow after solve DAE, ',num2str(caseName)),invBus);
    plotPowGraph(G,knownChange1,strcat('Power network, change in nodal pow from fsolve, ',num2str(caseName)),invBus);
    plotPowGraph(G,knownChange2,strcat('Power network, change in nodal pow from solving DAE, ',num2str(caseName)),invBus);


 %%
% plot Bound I DAE results
figure; 
subplot(2,2,2);
plot(t,y(:,26),t,y(:,13),'LineWidth',2); legend('V_{term}','V_{ref}'); xlabel('time (s)'); ylabel('voltage (V)'); 
subplot(2,2,1);
plot(t,repmat(inverter_params.Pnom,size(y(:,15),1),1),t,y(:,24),'LineWidth',2); legend('Pnom','Pt');  xlabel('time (s)'); ylabel('real power (W)'); 
sgtitle('Bound I Inv with 5-bus Nwk');
subplot(2,2,3);
plot(t,y(:,11).*y(:,26),'LineWidth',2); legend('Pgen'); xlabel('time (s)'); ylabel('real power (W)'); 
subplot(2,2,4);
plot(t,y(:,12).*y(:,26),'k-','LineWidth',2); legend('Qgen'); xlabel('time (s)'); ylabel('reactive power (VARs)'); 

% for debugging, see big jump from fsolve then DAE
printmat([x0(26) x0(24); x00(26) x00(24); y(1:3,26) y(1:3,24)], 'First Few Iter', 'x0 x00 time0.1 time0.2 time0.3','Vterm Pt')


%% Print values of some states
y(1:3,:)

%start=0/Ts;
start=1;
stop=4/Ts;
checkStop=stop<runItvl(end)/Ts
data=y(start:stop,end-3:end);
rowHeader=sprintf('tstep%d ', (start:stop)*Ts);
printmat(data,'Output dyn sim', rowHeader,'Pt Qt Vterm Vterm_theta')

    %% Create graph of network and LODF/PTDF

   targetBus=invBus; % arbitrary
    targetLine=2; % arbitrary
    slackBus=find(c.bus(:,2)==1);
    % each col is for reference line/bus, rows are how other lines are affected
    myH=myPTDF(c,slackBus); % nbr x nb
    myL=myLODF(c,slackBus); % nbr x nbr, uses PTDF to compute so need refBus as param
    % Compare with MATPOWER built in function
   Hcorr=makePTDF(c,slackBus); % (num branches)x(num buses)
   LODFcorr=makeLODF(c.branch,Hcorr);
   tol=1e-4;
   checkH=nnz(all(abs(Hcorr-myH)<tol))/size(Hcorr,2) % percentage of Hcorr ele that match myH, want to be close to 1 to show correctness of PTDF computation
   checkL=nnz(all(abs(LODFcorr-myL)<tol))/size(LODFcorr,2) % percentage of LODFcorr that match myL
       
    % build edge coordinates
    xcoors=c.branch(:,1); ycoors=c.branch(:,2);
    Hweights=myH(:,targetBus);
    Lweights=myL(:,targetLine);

    % build graph
    G=graph(xcoors,ycoors,Hweights);
    LWidths = abs(5*G.Edges.Weight/max(abs(G.Edges.Weight))); % make line thickness proportional to edge weight
    figure; h=plot(G,'EdgeLabel',G.Edges.Weight,'LineWidth',LWidths); title(strcat('PTDF: affect of power injection on line flows,',num2str(caseName)));
    
    highlight(h,targetBus,'NodeColor','r')
    clear G
    G=graph(xcoors,ycoors,Lweights);
    LWidths = abs(5*G.Edges.Weight/max(abs(G.Edges.Weight))); % make line thickness proportional to edge weight
    figure; h=plot(G,'EdgeLabel',G.Edges.Weight,'LineWidth',LWidths);  title(strcat('LODF: affect of line outage on line flows,',num2str(caseName)));
    highlight(h,c.branch(targetLine,1),c.branch(targetLine,2),'EdgeColor','r','LineWidth',1.5)
