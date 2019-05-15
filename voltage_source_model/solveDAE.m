%This is the Thevenin Voltage Source Equivalent to the Boundary Current
%Model for modeling the inverter for CIGs

clc;
close all;
clear all;

%% Load System Models and Parameters

%right now everything in same folder
parameters; % call parameters.m to populate workspace
            % includes power controller, current loop, thevenin voltage
            % source, coupling impedance parameters, inf bus parameters

Ts = 0.1;   % time step size
            % if too large --> won't see effects of delay constants
            % if too small --> not realistic
            
%% Converter Model with Infinite Bus 

stateLabel_inv_infbus = 's1 s2 s3 s4 s5 IQcmd IPcmd s6(iq) s7(id) Ed Eq s8 s9 Vt theta_conv Qg Pactual omega Ed_star Eq_star'; %order of states

% Use fsolve to initialize states
options_fsolve = optimoptions('fsolve','Algorithm','Levenberg-Marquardt',...
   'StepTolerance', 1e-8,'FunctionTolerance', 1e-5,'MaxFunctionEvaluations',...
   500000, 'MaxIterations',100000,'StepTolerance',1e-5,'OptimalityTolerance', 1e-8);

x00_inv_infbus = fsolve(@(x)VoltageSource_InfBus(0,x,inverter_params),x0_inv_infbus,options_fsolve);

printmat([x0_inv_infbus x00_inv_infbus], 'Initial States', stateLabel_inv_infbus, 'x0 x00')

%% Set up Mass Matrix to solve DAE
% Should have 1's corresponding to diff eqs, 0 corresponding to alg eqns
n = 20;     % number of states (in x)
M = eye(n);
% M(1,1) - M(5,5) -> ds1/dt - ds5/dt -> 1
M(6,6) = 0;     %IQcmd
M(7,7) = 0;     %IPcmd
% M(8,8) - M(9,9) -> ds6/dt - ds7/dt -> 1
M(10,10) = 0;   % Ed
M(11,11) = 0;   % Eq
% M(12,12) - M(13,13) -> ds8/dt - ds9/dt -> 1

%%M(14,14) = 0;   % Pline
%%M(15,15) = 0;   % Qline

M(14,14) = 0;   % Vt
M(15,15) = 0;   % theta_conv
M(16,16) = 0;   % Qg
M(17,17) = 0;   % Pactual
%M(18,18) -> domega/dt -> 1

M(19,19) = 0;   % Ed_star
M(20,20) = 0;   % Eq_star

% Set options for Mass Matrix
options = odeset('Mass', M, 'RelTol', 1e-8, 'AbsTol', 1e-6);

Sload=[];               % store load changes to plot later
runItvl = [0 2 4 6];    % time intervals for load changes

% Before step change in load Q
tspan1 = runItvl(1):Ts:runItvl(2);
Sload = [Sload repmat(inverter_params.Sload,1,length(tspan1))];     % populate array holding Sload parameters for each time interval

%don't use x00 in ode15s, so that we make sure perturbation is at the start
[t1,y1] = ode15s(@(t,x)VoltageSource_InfBus(t,x,inverter_params),tspan1,x0_inv_infbus,options);


% Change load (Increase Qload, leave Pload the same)
a = inverter_params.Sload;
inverter_params.Sload = 1*real(a) + j*1.5*imag(a);      % change in constant power load

% After step change in Qload
tspan2 = runItvl(2):Ts:runItvl(3);
Sload = [Sload repmat(inverter_params.Sload,1,length(tspan2))];
x1 = y1(end,:)';                                         % for next ode15s call
[t2,y2] = ode15s(@(t,x)VoltageSource_InfBus(t,x,inverter_params),tspan2,x1,options);

% Change load (Decrease Pload, leave Qload the same)
a=inverter_params.Sload;
inverter_params.Sload=0.8*real(a)+j*1*imag(a);          % change in constant power load

%After step change in Pload
tspan3 = runItvl(3):Ts:runItvl(4);
Sload = [Sload repmat(inverter_params.Sload,1,length(tspan3))];
x2 = y2(end,:)';                                         % for next ode15s call
[t3,y3] = ode15s(@(t,x)VoltageSource_InfBus(t,x,inverter_params),tspan3,x2,options);

x3 = y3(end,:)';
printmat([x0_inv_infbus x00_inv_infbus x1 x2 x3], 'Initial States', stateLabel_inv_infbus, 'x0 x00 x1 x2 x3')

% % Set up time span vector
% tspan = 0:Ts:1; %HAVE AN ERROR WHEN I EXTEND THIS TIME
% 
% % Solve DAEs - steady state
% 
% [t, y] = ode15s(@(t,x)VoltageSource_InfBus(t,x,inverter_params),tspan,x0_inv_infbus,options);
% 
% figure(1)
% plot(y(:,6))

t = [t1; t2; t3];
y = [y1; y2; y3];

   
%% Plot DAE results
% figure(1); 
% plot(t,real(Sload),t,imag(Sload),'k-','LineWidth',2); 
% legend('Pload','Qload','Location','Best'); 
% title('Load change disturbance'); 
% xlabel('time (s)'); 
% ylabel('power (W or VARs)');

% subplot(2,2,1);
% plot(t,repmat(inverter_params.Pnom,size(y(:,17),1),1),t,y(:,15),'LineWidth',2); 
% legend('P_{nom}','P_{actual}');  
% xlabel('time (s)'); 
% ylabel('real power (W)'); 
% %sgtitle('Bound I Inv with Inf Bus');

% subplot(2,2,1);
% plot(t,y(:,19),t,y(:,10),'LineWidth',2); 
% legend('Ed^{*}','Ed','Location','Best'); 
% xlabel('time (s)'); 
%ylabel('real power (W)'); 


figure(2);
subplot(2,2,1);
plot(t,y(:,18),t,repmat(inverter_params.omega_s,size(y(:,18),1),1),'LineWidth',2); 
legend('\omega','\omega_{s}','Location','Best'); 
xlabel('time (s)'); 
ylabel('angular frequency (per-unit)');
 
subplot(2,2,2);
plot(t,y(:,14),t,repmat(inverter_params.Vref,size(y(:,14),1),1),'LineWidth',2);
%plot(t,y(:,13),t,y(:,17),'LineWidth',2);
legend('V_{t}','V_{ref}','Location','Best'); 
xlabel('time (s)'); 
ylabel('voltage (V)'); 

subplot(2,2,3);
plot(t,y(:,17),'LineWidth',2); 
legend('P_{actual}','Location','Best'); 
xlabel('time (s)'); 
ylabel('real power (W)'); 

subplot(2,2,4);
plot(t,y(:,16),'k-','LineWidth',2); 
legend('Q_{g}','Location','Best'); 
xlabel('time (s)'); 
ylabel('reactive power (VARs)'); 


figure(3)
subplot(2,1,1);
plot(t,y(:,10),t,y(:,19),'Linewidth',2);
legend('Ed','Ed^{*}','Location','Best');
xlabel('time(s)')
ylabel('Voltage (V)')

subplot(2,1,2);
plot(t,y(:,11),t,y(:,20),'Linewidth',2);
legend('Eq','Eq^{*}','Location','Best');
xlabel('time(s)')
ylabel('Voltage (V)')

    
    
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


