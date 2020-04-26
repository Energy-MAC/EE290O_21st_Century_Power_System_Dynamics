% OLD VERSION
% builds DAE for boundary I inv + 5-bus network :
function dxdt = boundaryinv_network(t,x,c,params,Ts,invBus,knowns);
V=knowns{1}; del=knowns{2}; P=knowns{3}; Q=knowns{4};

dxdt=[]; % will fill this
% input c is case struct for power network from MATPOWER
N = size(c.bus,1);
L = size(c.branch,1);
%[Ybus,Yf,Yt]=makeYbus(c); % Yt almost the same as Y

% Known values, hard to generalize by pulling from c
%  Qmeas(4)=-0.5365;
%  Pmeas=[2.0988 -3.0021 0.2373 -3.9497 4.666]';
% vmagVec=[1 0.989 1 1 1]';
% thetaVec_deg=[3.273 -0.759 -0.492  0 4.112]'; % degrees
% thetaVec=thetaVec_deg*(pi/180); % convert to radians

   [M_k,Y_k,Ybar_k,Y_lm,Ybar_lm,Y_ml,Ybar_ml]=computeYmats(c);
 %% PF equation matrix formulas
    h_V=@(x,M_k) trace(M_k*x*x'); % note Tr(Mk*x*x')=V^2, not V!
    h_P=@(x,Y_k) trace(Y_k*x*x');
    h_Q=@(x,Ybar_k) -trace(Ybar_k*x*x');
    h_Pline=@(x,Y_lm) trace(Y_lm*x*x'); % can take in l-->m or m-->l Y matrices
    h_Qline=@(x,Ybar_lm) -trace(Ybar_lm*x*x'); % add neg to make sign convention agree with runpf and vYv formulation
    %x=[real(V)' imag(V)']'

    
%% Collect knowns from case
% vmagVec=c.bus(:,8).*c.bus(:,10); % units=V, pu*base=actual
% thetaVec_deg=c.bus(:,9); % units=degrees
% thetaVec=thetaVec_deg*(pi/180); % convert to radians

%% build dxdt equations
    nInvState=17-4;
    ofs=nInvState; % offset state assignment to not overwrite inv states

    x_QVdroop=x(1:3); % internal states gi, no specific name
    Qcmd=x(4);
    Iqcmd=x(5); 
    Ipcmd=x(6);
    w=x(7);
    Pcmd=x(8);
    x_phys=x(9:10); % internal states gi
    Ipterm=x(11);
    Iqterm=x(12);
%     Vterm=x(13); 
%     Vterm_theta=x(14);
%     Pt=x(15);
%     Qt=x(16);
    Vref=x(13);
    
    Pt=x(ofs+2*N+1);
    Qt=x(ofs+2*N+2);
    Vterm=x(ofs+2*N+3);
    Vterm_theta=x(ofs+2*N+4);
    
    dxdt=[dxdt;...
      %% Now add inverter eqns
    QVdroop(x_QVdroop,Vterm,Vref,Qcmd,params); % 4 diff eq, g1/g2/g3/Qcmd
    current_control2(Qcmd,Pt,Vterm,Iqcmd,Ipcmd,Pcmd,params); % 2 diff eq, 3 alg, mixed ordering
    physConv(x_phys,Ipcmd,Iqcmd,Ipterm,Iqterm,params); % 2 diff eq, 2 alg, g1/g2/Ipterm/Iqterm
    0; % d(Vref)=0
];

%% add in PF eqns assoc with network
    for k = 1:N % creat 2*N bus equations, after this state vector is (ofs+2N)x1
            busType=c.bus(k,2);           
            switch busType % take different measurements at diff bus types
                case 1 % slack bus
                    % fill in unknowns
                    P(k)=x(ofs+2*k-1);
                    Q(k)=x(ofs+2*k);
                    % fill in knowns
                    V=vmagVec; 
                    del=thetaVec;    
                    
                    % setup eqns with rest of unknowns
                    dxdt=[dxdt; -P(k)+h_P([V; del],Y_k{k})]; % create with possibilities of unknowns
                    dxdt=[dxdt; -Q(k)+h_Q([V; del],Ybar_k{k})]; % create with possibilities of unknowns

                case 2 % gen bus 
                    % fill in unknowns
                    del=thetaVec; del(k)=x(ofs+2*k-1);
                    Q(k)=x(ofs+2*k);
                    % fill in knowns
                    V=vmagVec; 
                    P(k)=c.gen(k,2);  
                    % setup eqns with rest of unknowns
                    dxdt=[dxdt; -P(k)+h_P([V; del],Y_k{k})]; % create with possibilities of unknowns
                    dxdt=[dxdt; -Q(k)+h_Q([V; del],Ybar_k{k})]; % create with possibilities of unknowns

                case 3 % load bus
                    % fill in unknowns
                    V=vmagVec; V(k)=x(ofs+2*k-1);
                    del=thetaVec; del(k)=x(ofs+2*k);
                    % fill in knowns
                    if k==invBus
                        % need eqns for setting Qt,Pt,Vterm, Vterm_theta
                        Q(k)=c.bus(k,4)-Vterm*Iqterm; 
                        P(k)=c.bus(k,3)-Vterm*Ipterm; 
                       eqn=[-P(k)+Pt;...
                           -Q(k)+Qt;...
                            Vterm-V(k);...
                            Vterm_theta-del(k)]; % save for after this loop                           
                    else
                        Q(k)=c.bus(k,4); 
                        P(k)=c.bus(k,3);
                    end
                    % solve for V & del
                    dxdt=[dxdt; -P(k)+h_P([V; del],Y_k{k})]; % create with possibilities of unknowns
                    dxdt=[dxdt; -Q(k)+h_Q([V; del],Ybar_k{k})]; % create with possibilities of unknowns
            end
    end
    dxdt=[dxdt; eqn]; % append to dxdt at end so can align with x asignments
end

%% Tips:
% Inverter needs to be initialized as PQ bus instead of generator bus because it doesn’t regulate V directly
% Why does this make sense? generator bus has P/V known, while PQ bus has
% net P/Q known, and in this case we do know P and Q as Pnet=Pinv-Pload,
% where we essentially have a PQ bus then add an inverter (nodal power
% injection) on top. Initial PF solving just needs a modification to add
% Pinv,Qinv into net nodal power at desired node
% Questions: 
% (1) How does rest of grid update after initialize wih PF run? The DAE
% solver either implicitly or explicitly solves alg and diffeqs at each
% timstep, the implicit vs. explicit refers to a batch (implicit) vs.
% iterative (explicit) solving method
% At each bus there are 2 knowns and 2 unknowns. At each timestep are we
% updating knowns, unknowns, or both?

% Review how to solve power flow: we start with an initial guess on the set
% of all voltages then use the functions that relate voltages to
% measurements to det guess of P,Q. Now we have 2 knowns per bus. Then we
% do soliving algo which tries to arrive at a soln of voltages. Once we
% have the soln, we use the functions again to compute the rest of the
% flows

% let V/del be a guess for the buses that have unknown V and/or del
% let P/G knowns be the known net power generation at buses that have known
% P and/or G
% the solving algo reconciles how you claim to know all quantities with the
% fact that the PF equations have to hold, until you arrive at a soln; %
% the soln modifies V/del guess to satisfy the PF eqns, does not modify
% known V/del/P/Q

% PQ: know PQ, dont know V/del
% PV: know PV, dont know Q,del
% slack: know V/del, dont know P/Q
% (1) V/delguess+P/Gknowns --> (2) V/del soln --> (3) P/Qsoln
%  in each arrow is algebraic equations

% in DAE: x0 has (1)
% unknowns are states
% knowns are params
% P/Qguess=0, V/delguess = 1
% how do we extract knowns from the case structure? the info seems to be available
% do the knowns change in value during the dynamic sim? No, assume even V at PV bus doesnt change. 
% The PQinv bus known PQ will be set differently at each timestep b/c of inv, and will affect the unknowns. However, for each solving of PF the PQ at that bus is still "known", just not constant across time like the other knowns
% how do we assign the knowns to be params? fill a vector during initialization, then assign the vector to be a param, pull from param each time you update dxdt
