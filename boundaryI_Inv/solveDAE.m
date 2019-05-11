% OLD VERSION
% Version with triple integrator in inverter model
%--------------------------------------------

% caseName='case5';
% c = loadcase(caseName);
% N = size(c.bus,1);
% L = size(c.branch,1);
% % MATPOWER manual ch 9.3.5 tells us how to modify a case
% % modify case to have the same
% cnew=extract_islands(c)

% 1) write equations yourself for small network with your own NR code, set inv to be const, run
% 2) compare with MATPOWER solving PF after modify generator to be same as inv rating
% 3) restructure MATPOWER network data into algebraic equation format so can
% be solve with DAE

% When changing state vector need to update:
% 1. block eqs
% 2. dxdt
% x0 in params.m
% DAE mass matrix M
% stateLabel string
%%
% Jaimie Swartz
clc; close all; clear all;
%%Load System Models and Parameters
% addpath(genpath('device_models'))
% addpath('utils')

parameters % call the parameters.m to set populate workspace
% after calling, workspace will have "inverter_params" and x0 vars
Ts=0.1; % if choose too large you wont see delay constants effecting, if choose too fast not realistic sample time

%% Bus inf simple, which is only 2 algebraic equations for power flow
% FSOLVE to initialize
% options_dae = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
 stateLabel2='Vterm Vterm_theta Iqterm Ipterm Pline Qline';
 x00_test2 = fsolve(@(x)bound_infSimple(0,x,inverter_params),x0_test2);
 printmat([x0_test2 x00_test2], 'Init States', stateLabel2,'x0 x00_test2')

% % solve DAE
% n=6; % num states
% M=eye(n);
% M(5,5)=0; M(6,6)=0;
% tspan = 0:Ts:1;
%  options = odeset('Mass',M,'RelTol',1e-4,'AbsTol',1e-6);
%  [t,y] = ode15s(@(t,x)bound_infSimple(t,x,inverter_params),tspan,x00_test2,options);
% 
% % plot Bus inf simple results
% % always get constant plit because there are no dynamics, computation is
% % static so time does not affect the computation
% figure; 
% subplot(3,1,1);
% plot(t,y(:,5),t,y(:,6),'LineWidth',2); legend('Pline','Qline');
% subplot(3,1,2);
% plot(t,y(:,3),t,y(:,4),'LineWidth',2); legend('Ipterm','Iqterm');
% subplot(3,1,3);
% plot(t,y(:,1),t,y(:,2),'LineWidth',2); legend('Vterm','Vterm_theta');
% sgtitle('Bound Inf Simple');

%% Bound I DAE
% FSOLVE to initialize
 stateLabel1='x_QVdroop x_QVdroop x_QVdroop Qcmd I_ctrl Ipcmd Iqcmd w Pcmd x_phys x_phys Ipterm Iqterm Vterm Vterm_theta Pgen Qgen Vref';
x00_test1 = fsolve(@(x)boundaryinv_infBus(0,x,inverter_params,Ts),x0_inv);
xdot_init=boundaryinv_infBus(0,x00_test1,inverter_params,Ts) % for debugging: compute xdot at first timestep
printmat([x0_inv x00_test1 xdot_init], 'Init States', stateLabel1,'x0 x00_test1 xdot')

%printmat([x0_inv xdot_init], 'Init States', stateLabel1,'x0 xdot')

% solve DAE
n=18; % num states
M=eye(n);
M(6,6)=0; M(8,8)=0; M(12,12)=0; M(13,13)=0; M(14,14)=0; M(15,15)=0; M(16,16)=0; M(17,17)=0;

% before step change in load
    tspan1 = 0:Ts:10;
    options = odeset('Mass',M,'RelTol',1e-4,'AbsTol',1e-6);
    [t1,y1] = ode15s(@(t,x)boundaryinv_infBus(t,x,inverter_params,Ts),tspan1,x0_inv,options);

inverter_params.ZL=100+100*j; % load, complex

% after step change in load
    tspan2 = 10:Ts:20;
    x0 = y1(end,:);
    [t2,y2] = ode15s(@(t,x)boundaryinv_infBus(t,x,inverter_params,Ts),tspan2,x0,options);
    t = [t1; t2];
    y = [y1; y2];
 %%
 
% plot Bound I DAE results
figure; plot(t,y(:,4),'LineWidth',2); legend('Qcmd');
figure; 
subplot(2,2,2);
plot(t,y(:,14),t,y(:,18),'LineWidth',2); legend('V_{term}','V_{ref}'); 
subplot(2,2,1);
plot(t,y(:,8),t,y(:,15),'LineWidth',2); legend('w','V_{term theta}'); 
sgtitle('Bound I Inv with Inf Bus');
subplot(2,2,3);
plot(t,y(:,12).*y(:,14),'LineWidth',2); legend('Pgen');
subplot(2,2,4);
plot(t,y(:,13).*y(:,14),'k-','LineWidth',2); legend('Qgen');


start=9/Ts;
stop=11/Ts;
data=[y(start:stop,12).*y(start:stop,14) y(start:stop,13).*y(start:stop,14) y(start:stop,12) y(start:stop,13) y(start:stop,14) y(start:stop,18) y(start:stop,8) y(start:stop,15)];
rowHeader=sprintf('tstep%d ', (start:stop)*Ts);
printmat(data,'Output dyn sim', rowHeader,'Pgen Qgen Ipterm Iqterm Vterm Vref w Vterm_theta')
%%
%% TIPS
% refernce for mass matrix: https://www.mathworks.com/help/matlab/math/solve-differential-algebraic-equations-daes.html
% use fsolve to solve PF and initialize
% use ODE23t or 15s to run dyn sim
%If you are only interested in the steady state behavior,you should use "fsolve" instead of "ODE45" - it should be much faster.

%% Step change in param:
% https://www.mathworks.com/matlabcentral/answers/5336-nonlinear-system-of-differential-algebraic-equations
% You should run the integration with the first parameter to the time of your step change and then use the output as the initial condition for a new run using the second parameter.
% EDIT: Suppose your function is f(x,param) and x has length 2. You could do something like this:
% param = 5;
% odefun = @(x) f(x,param);
% tspan = [0 100];
% x0 = [0; 0];
% [t1,x1]  = ode15s(odefun,tspan,x0);
% param = 6;
% odefun = @(x) f(x,param);
% tspan = [100 200];
% x0 = x1(:,end);
% [t2,x2]  =  ode15s(odefun,tspan,x0);
% t = [t1 t2];
% x = [x1 x2];