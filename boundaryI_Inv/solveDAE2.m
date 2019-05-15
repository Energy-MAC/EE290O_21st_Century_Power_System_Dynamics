% SolveDAE2 got rid of triple integration in current block compared to
% solveDAE
% ----------------------------------

% When changing state vector need to update:
% 1. block eqs
% 2. dxdt
% x0 in params.m
% DAE mass matrix M
% stateLabel string
% plot y indices
%%
% Jaimie Swartz
clc; close all; clear all;

parameters % call the parameters.m to set populate workspace
% after calling, workspace will have "inverter_params" and x0 vars
Ts=0.1; % if choose too large you wont see delay constants effecting, if choose too fast not realistic sample time

%% Bound I DAE
% FSOLVE to initialize
 stateLabel1='x_QVdroop x_QVdroop x_QVdroop Qcmd Iqcmd Ipcmd w Pcmd x_phys x_phys Ipterm Iqterm Vterm Vterm_theta Pt Qt Vref';
%options_dae = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);

 x00_test1 = fsolve(@(x)boundaryinv_infBus2(0,x,inverter_params,Ts),x0_inv);
xdot_init=boundaryinv_infBus2(0,x00_test1,inverter_params,Ts); % for debugging: compute xdot at first timestep
printmat([x0_inv x00_test1 xdot_init], 'Init States', stateLabel1,'x0 x00_test1 xdot')

%printmat([x0_inv xdot_init], 'Init States', stateLabel1,'x0 xdot')

% solve DAE
n=17; % num states
M=eye(n);
M(5,5)=0; M(6,6)=0; M(11,11)=0; M(12,12)=0; M(13,13)=0; M(14,14)=0; M(15,15)=0; M(16,16)=0;
options = odeset('Mass',M,'RelTol',1e-4,'AbsTol',1e-6);
runItvl=[0 2 4 6];
Sload=[]; % store load changes to plot later

% before step change in load Q
    tspan1 = runItvl(1):Ts:runItvl(2);
    Sload=[Sload repmat(inverter_params.Sload,1,length(tspan1))];
    [t1,y1] = ode15s(@(t,x)boundaryinv_infBus2(t,x,inverter_params,Ts),tspan1,x00_test1,options);

    a=inverter_params.Sload;
    inverter_params.Sload=1*real(a)+j*1.5*imag(a) % chang in const pow load

% after step change in load P
    tspan2 = runItvl(2):Ts:runItvl(3);
    Sload=[Sload repmat(inverter_params.Sload,1,length(tspan2))];
    x0 = y1(end,:); % for next ODE15s call
    [t2,y2] = ode15s(@(t,x)boundaryinv_infBus2(t,x,inverter_params,Ts),tspan2,x0,options);

    a=inverter_params.Sload;
    inverter_params.Sload=0.8*real(a)+j*1*imag(a) % chang in const pow load

% after step change in ws ref
    tspan3 = runItvl(3):Ts:runItvl(4);
    Sload=[Sload repmat(inverter_params.Sload,1,length(tspan3))];
    x0 = y2(end,:); % for next ODE15s call
    [t3,y3] = ode15s(@(t,x)boundaryinv_infBus2(t,x,inverter_params,Ts),tspan3,x0,options);

    t = [t1; t2; t3];
    y = [y1; y2; y3];
    

 %% plot Bound I DAE results
figure; plot(t,real(Sload),t,imag(Sload),'k-','LineWidth',2); legend('Pload','Qload'); title('Load change disturbance'); xlabel('time (s)'); ylabel('power (W or VARs)');
figure; 
subplot(2,2,2);
plot(t,y(:,13),t,y(:,17),'LineWidth',2); legend('V_{term}','V_{ref}'); xlabel('time (s)'); ylabel('voltage (V)'); 
subplot(2,2,1);
plot(t,repmat(inverter_params.Pnom,size(y(:,15),1),1),t,y(:,15),'LineWidth',2); legend('Pnom','Pt');  xlabel('time (s)'); ylabel('real power (W)'); 
sgtitle('Bound I Inv with Inf Bus');
subplot(2,2,3);
plot(t,y(:,11).*y(:,13),'LineWidth',2); legend('Pgen'); xlabel('time (s)'); ylabel('real power (W)'); 
subplot(2,2,4);
plot(t,y(:,12).*y(:,13),'k-','LineWidth',2); legend('Qgen'); xlabel('time (s)'); ylabel('reactive power (VARs)'); 

%% Print values of some states
%start=0/Ts;
start=1;
stop=4/Ts;
checkStop=stop<runItvl(end)/Ts
data=[y(start:stop,11).*y(start:stop,13) y(start:stop,12).*y(start:stop,13) y(start:stop,11) y(start:stop,12) y(start:stop,13) y(start:stop,17) y(start:stop,7) y(start:stop,14)];
rowHeader=sprintf('tstep%d ', (start:stop)*Ts);
printmat(data,'Output dyn sim', rowHeader,'Pgen Qgen Ipterm Iqterm Vterm Vref w Vterm_theta')

Vterm0_rec=y(1,13) % from running DAE once set Vterm0 in params file to be this
% this is heuristic for finding init cond since fsolve and analytics cant predict it
