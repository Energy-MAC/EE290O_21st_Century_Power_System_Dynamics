%% Power Controller Parameters
%reference: Modeling of GE Solar PV plans for grid studies (Apr 2010)
% http://files.engineering.com/download.aspx?folder=72244e74-9cb5-4d18-8ce1-e25fd1b01866&file=GE_Solar_Modeling-v1-1.pdf

% "The aggergate solar plant is modeled as a conventional generator
% connected to a 480V bus. The generator real power output (Pgen), Qmin,
% and Qmax should match the solar plant capability


%% Load flow parameters, which initializaes dynamic sim
% right now, setting values to match GE PV plans, taken from Table 2-1
% -real power order = combo of power setpoint and active power droop coeff
% -reactive power order = combo of voltage error and reactive power droop

% %inputs
% inverter_params.Vt
% inverter_params.Qg
% inverter_params.omega
% inverter_params.Pactual
% 
% %intermediate outputs
% inverter_params.Qcmd
% inverter_params.Pcmd
% 
% %limits
% %should set to limits as described on pg. 45 in rama thesis
% inverter_params.Pmax; % kW
% inverter_params.Qmax;  % kVar, for 0.99 power factor
% inverter_params.Qmin; % kVar
% 
% %reference points
% inverter_params.Vref % V
% inverter_params.Pref
% inverter_params.omega_s = 377;   % rad/s
% %QV droop (is this right?)
% % needed to obtain stable operation between converers when multiple
% % converters connected to same bus
% inverter_params.Rq
% inverter_params.Rp
% 
% %Outer current loop
%     %reactive power controller
% inverter_params.Ki
% inverter_params.Kp
% inverter_params.Kiq = 10.0; 
% inverter_params.Tr
% 
%     %real power controller
% inverter_params.Tfrq
% inverter_params.TGpv
% inverter_params.Kip = 10.0;
% 
% %outputs from power controller (inputs to inner current loop)
% inverter_params.Iqcmd
% inverter_params.Ipcmd
% 
% 
% %Inner current loop - real and reactive
% inverter_params.Td = 10e-3;     % sec
% inverter_params.Tq = 10e-3;     % sec
% inverter_params.Imax    %current limit
% 
% 
% %PWM stage
% inverter_params.Teq = 10e-3;    % sec
% inverter_params.Ted = 10e-3;    % sec
% 
% inverter_params.Vdc
% inverter_params.VT
% 
% %coupling impedance
% inverter_params.Rf
% inverter_params.Xf

% inf bus network
inverter_params.Xe=0.5;
inverter_params.ZL=0.5;
inverter_params.Vinf=480;
inverter_params.theta_inf = 0;


%x0 starting states

% for infinite bus example 
% Vt=550, Vinf=480, so expect power flow from inv to inf bus
x0_bus_inf = [550 0 0 0 0 0]';

    