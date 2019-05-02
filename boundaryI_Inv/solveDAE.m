
%%
clc; close all; clear all;
%%Load System Models and Parameters
% addpath(genpath('device_models'))
% addpath('utils')

parameters % call the parameters.m to set populate workspace
% after calling, workspace will have "inverter_params" and x0 vars
Ts=0.05;

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
 stateLabel1='x_QVdroop x_QVdroop x_QVdroop Qcmd I_ctrl I_ctrl Ipcmd Iqcmd x_phys x_phys Iqterm Ipterm Pline Qline Vterm Vterm_theta Vref';
x00_test1 = fsolve(@(x)boundaryinv_infBus(0,x,inverter_params),x0_test1);
 printmat([x0_test1 x00_test1], 'Init States', stateLabel1,'x0 x00_test1')

% solve DAE
n=17; % num states
M=eye(n);
M(7,7)=0; M(11,11)=0; M(12,12)=0; M(13,13)=0; M(14,14)=0;
tspan = 0:Ts:1;
 options = odeset('Mass',M,'RelTol',1e-4,'AbsTol',1e-6);
 [t,y] = ode15s(@(t,x)boundaryinv_infBus(t,x,inverter_params),tspan,x00_test1,options);

% plot Bound I DAE results
figure; 
subplot(3,1,1);
plot(t,y(:,13),t,y(:,14),'LineWidth',2); legend('Pline','Qline');
subplot(3,1,2);
plot(t,y(:,11),t,y(:,12),'LineWidth',2); legend('Ipterm','Iqterm');
subplot(3,1,3);
plot(t,y(:,15),t,y(:,16),'LineWidth',2); legend('Vterm','Vterm_theta'); 
sgtitle('Bound I');

%% TIPS
% refernce for mass matrix: https://www.mathworks.com/help/matlab/math/solve-differential-algebraic-equations-daes.html
% use fsolve to solve PF and initialize
% use ODE23t or 15s to run dyn sim