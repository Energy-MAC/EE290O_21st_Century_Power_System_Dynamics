

caseName='case5';
c = loadcase(caseName);
N = size(c.bus,1);
L = size(c.branch,1);
% MATPOWER manual ch 9.3.5 tells us how to modify a case
% modify case to have the same
cnew=extract_islands(c)

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
Ts=0.05

%% Bus inf simple, which is only 2 algebraic equations for power flow
% FSOLVE to initialize
% options_dae = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
 stateLabel2='Vterm Vterm_theta Iqterm Ipterm Pline Qline';
 x00_test2 = fsolve(@(x)bound_infSimple(0,x,inverter_params),x0_test2);
 printmat([x0_test2 x00_test2], 'Init States', stateLabel2,'x0 x00_test2')

% solve DAE
n=6; % num states
M=eye(n);
M(5,5)=0; M(6,6)=0;
tspan = 0:Ts:1;
 options = odeset('Mass',M,'RelTol',1e-4,'AbsTol',1e-6);
 [t,y] = ode15s(@(t,x)bound_infSimple(t,x,inverter_params),tspan,x00_test2,options);

% plot Bus inf simple results
% always get constant plit because there are no dynamics, computation is
% static so time does not affect the computation
figure; 
subplot(3,1,1);
plot(t,y(:,5),t,y(:,6),'LineWidth',2); legend('Pline','Qline');
subplot(3,1,2);
plot(t,y(:,3),t,y(:,4),'LineWidth',2); legend('Ipterm','Iqterm');
subplot(3,1,3);
plot(t,y(:,1),t,y(:,2),'LineWidth',2); legend('Vterm','Vterm_theta');
sgtitle('Bound Inf Simple');

%% Bound I DAE
% FSOLVE to initialize
 stateLabel1='x_QVdroop x_QVdroop x_QVdroop Qcmd I_ctrl Ipcmd Iqcmd w Pcmd Vterm_theta x_phys x_phys Ipterm Iqterm Pline Qline Vterm Pref Vref';
x00_test1 = fsolve(@(x)boundaryinv_infBus(0,x,inverter_params),x0_test1);
xdot_init=boundaryinv_infBus(0,x00_test1,inverter_params) % for debugging: compute xdot at first timestep
printmat([x0_test1 x00_test1 xdot_init], 'Init States', stateLabel1,'x0 x00_test1 xdot')

%printmat([x0_test1 xdot_init], 'Init States', stateLabel1,'x0 xdot')

% solve DAE
n=18; % num states
M=eye(n);
M(6,6)=0; M(9,9)=0; M(13,13)=0; M(14,14)=0; M(15,15)=0; M(16,16)=0;
tspan = 0:Ts:1;
 options = odeset('Mass',M,'RelTol',1e-4,'AbsTol',1e-6);
 [t,y] = ode15s(@(t,x)boundaryinv_infBus(t,x,inverter_params),tspan,x0_test1,options);

% plot Bound I DAE results
figure; 
subplot(3,2,1);
plot(t,y(:,13),'LineWidth',2); legend('Ipterm');
subplot(3,2,2);
plot(t,y(:,14),'k-','LineWidth',2); legend('Iqterm');
subplot(3,2,3);
plot(t,y(:,17),t,y(:,18),'LineWidth',2); legend('V_{term}','V_{ref}'); 
subplot(3,2,4);
plot(t,y(:,8),t,y(:,10),'LineWidth',2); legend('w','V_{term theta}'); 
sgtitle('Bound I Inv with Inf Bus');
subplot(3,2,5);
plot(t,y(:,15),'LineWidth',2); legend('Pline');
subplot(3,2,6);
plot(t,y(:,16),'k-','LineWidth',2); legend('Qline');

data=[y(:,15) y(:,16) y(:,13) y(:,14) y(:,17) y(:,18) y(:,8) y(:,10)];
rowHeader=sprintf('tstep %d ', 1:size(data,1));
printmat(data,'Output dyn sim', rowHeader,'Pline Qline Ipterm Iqterm Vterm Vref w Vterm_theta')

%%
figure; plot(t,y(:,6),t,y(:,7),t,y(:,10),t,y(:,11),'LineWidth',2); legend('Ipcmd','Iqcmd','Ipterm','Iqterm');
%% TIPS
% refernce for mass matrix: https://www.mathworks.com/help/matlab/math/solve-differential-algebraic-equations-daes.html
% use fsolve to solve PF and initialize
% use ODE23t or 15s to run dyn sim
%If you are only interested in the steady state behavior,you should use "fsolve" instead of "ODE45" - it should be much faster.