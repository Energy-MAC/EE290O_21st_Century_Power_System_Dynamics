%This is the Thevenin Voltage Source Equivalent to the Boundary Current
%Model for modeling the inverter for CIGs

clc;
close all;
clear all;

%% Load System Models and Parameters

%right now everything in same folder
parameters; % call parameters.m to populate workspace
            % includes power controller, thevenin voltage source, coupling
            % impedance parameters

Ts = 0.05;  % time step size

%% Converter Model with Infinite Bus 

% Use fsolve to initialize states
stateLabel_inv_infbus = 's1 s2 s3 s4 s5 s6(iq) s7(id) s8 s9 Vt Qg omega Pactual Qcmd Pcmd Iqcmd Ipcmd Ed Eq';
x00_inv_infbus = fsolve(@(x)VoltageSource_InfBus(0,x,inverter_params),x0_inv_infbus);
printmat([x0_inv_infbus x00_inv_infbus], 'Initial States', stateLabel_inv_infbus, 'x0 x00')

% Set up Mass Matrix to solve DAE
% Should have 1's corresponding to diff eqs, 0 corresponding to alg eqns
n = 19;     % number of states (in x)
M = eye(n);
%M(1,1) - M(9,9) -> ds1/dt - ds9/dt -> 1



% Set up time span vector
tspan = 0:Ts:1;

% Solve DAEs
options = odeset('Mass', M, 'RelTol', 1e-4, 'AbsTol', 1e-6);
[t, y] = ode15s(@(t,x)VoltageSource_InfBus(t, x, inverter_params), tspan, x00_inv_infbus,options);


%% Bus inf simple, which is only 2 algebraic equations for power flow
% % Use fsolve to initialize states
% 
% %setup labels for plots
% stateLabel2='Vterm Vterm_theta Iqterm Ipterm Pline Qline';               
% %resolve for initial states using fsolve 
% x00_bus_inf = fsolve(@(x)bound_infSimple(0,x,inverter_params),x0_bus_inf);
% %print initial state results
% printmat([x0_bus_inf x00_bus_inf], 'Init States', stateLabel2,'x0 x00')
% 
% % Set up Mass Matrix
% n=6;        % number of  states
% M=eye(n);
% M(5,5)=0; 
% M(6,6)=0;
% options = odeset('Mass',M,'RelTol',1e-4,'AbsTol',1e-6);
% 
% % Set up time span vector
% tspan = 0:Ts:1;
% 
% % Solve DAEs using x00 initial state
% [t,y] = ode15s(@(t,x)bound_infSimple(t,x,inverter_params),tspan,x00_bus_inf,options);
% 
% % plot Bus inf simple results
% % always get constant plot because there are no dynamics, computation is
% % static so time does not affect the computation
% figure; 
% subplot(3,1,1);
% plot(t,y(:,5),t,y(:,6),'LineWidth',2); legend('Pline','Qline');
% subplot(3,1,2);
% plot(t,y(:,3),t,y(:,4),'LineWidth',2); legend('Ipterm','Iqterm');
% subplot(3,1,3);
% plot(t,y(:,1),t,y(:,2),'LineWidth',2); legend('Vterm','Vterm_theta');
% title('Bound Inf Simple');


