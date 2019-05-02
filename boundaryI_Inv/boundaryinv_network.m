function dxdt = boundaryinv_network(t,x,c);
dxdt=[]; % will fill this
% input c is case struct for power network from MATPOWER
N = size(c.bus,1);
L = size(c.branch,1);
[Ybus,Yf,Yt]=makeYbus(c); % Yt almost the same as Y

% Known values, hard to generalize by pulling from c
 Qmeas(4)=-0.5365;
 Pmeas=[2.0988 -3.0021 0.2373 -3.9497 4.666]';
vmagVec=[1 0.989 1 1 1]';
thetaVec_deg=[3.273 -0.759 -0.492  0 4.112]'; % degrees
thetaVec=thetaVec_deg*(pi/180); % convert to radians

   [M_k,Y_k,Ybar_k,Y_lm,Ybar_lm,Y_ml,Ybar_ml]=computeYmats(c);
 %% PF equation matrix formulas
    h_V=@(x,M_k) trace(M_k*x*x'); % note Tr(Mk*x*x')=V^2, not V!
    h_P=@(x,Y_k) trace(Y_k*x*x');
    h_Q=@(x,Ybar_k) -trace(Ybar_k*x*x');
    h_Pline=@(x,Y_lm) trace(Y_lm*x*x'); % can take in l-->m or m-->l Y matrices
    h_Qline=@(x,Ybar_lm) -trace(Ybar_lm*x*x'); % add neg to make sign convention agree with runpf and vYv formulation
    %x=[real(V)' imag(V)']'

    
%% build dxdt equations
    for k = 1:N % creat 2*N bus equations
            busType=c.bus(k,2);
%             clear P; clear Q; clear V; clear del;
%             P=sym('P',[N 1]);
%             Q=sym('Q',[N 1]);
%             V=sym('V',[N 1]);
%             del=sym('del',[N 1]);
            
            switch busType % take different measurements at diff bus types
                case 1 % slack bus
                    % fill in unknowns
                    P(k)=x(2*k-1);
                    Q(k)=x(2*k);
                    % fill in knowns
                    V=vmagVec; 
                    del=thetaVec; 
                    % setup eqns with rest of unknowns
                    dxdt=[dxdt; -P(k)+h_P([V; del],Y_k{k})]; % create with possibilities of unknowns
                    dxdt=[dxdt; -Q(k)+h_Q([V; del],Ybar_k{k})]; % create with possibilities of unknowns

                case 2 % gen bus 
                    % fill in unknowns
                    del=thetaVec; del(k)=x(2*k-1);
                    Q(k)=x(2*k);
                    % fill in knowns
                    V=vmagVec; 
                    P(k)=Pmeas(k);  
                    % setup eqns with rest of unknowns
                    dxdt=[dxdt; -P(k)+h_P([V; del],Y_k{k})]; % create with possibilities of unknowns
                    dxdt=[dxdt; -Q(k)+h_Q([V; del],Ybar_k{k})]; % create with possibilities of unknowns

                case 3 % load bus
                    % fill in unknowns
                    V=vmagVec; V(k)=x(2*k-1);
                    del=thetaVec; del(k)=x(2*k);
                    % fill in knowns
                    Q(k)=Qmeas(k); 
                    P(k)=Pmeas(k);  
                    % setup eqns with rest of unknowns
                    dxdt=[dxdt; -P(k)+h_P([V; del],Y_k{k})]; % create with possibilities of unknowns
                    dxdt=[dxdt; -Q(k)+h_Q([V; del],Ybar_k{k})]; % create with possibilities of unknowns
            end
    end
end