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

% %limits
% %should set to limits as described on pg. 45 in rama thesis
% inverter_params.Pmax; % kW
% inverter_params.Qmax;  % kVar, for 0.99 power factor
% inverter_params.Qmin; % kVar

% %reference points
% inverter_params.Vref % V
% inverter_params.Pref
inverter_params.omega_s = 377;   % rad/s

%QV droop - values taken from Rama Thesis Table 5.1
% needed to obtain stable operation between converers when multiple
% converters connected to same bus
inverter_params.Rq = 0.0;   % per-unit
inverter_params.Rp = 0.05;  % per-unit

%Outer current loop - values taken from Rama paper Section B 
    %reactive power controller
inverter_params.Ki = 5.0; %(from thesis) %20.0;
inverter_params.Kp = 1.0; %(from thesis) %4.0;
inverter_params.Kiq = 10.0; 
inverter_params.Tr = 0.02;  % sec, from Rama thesis Table 5.1
 
    %real power controller
%inverter_params.Tfrq
inverter_params.TGpv = 0.01; % sec, from Rama thesis Table 5.1
inverter_params.Kip = 10.0;

%Inner current loop - real and reactive
inverter_params.Td = 0.01;     % sec
inverter_params.Tq = 0.01;     % sec

% inverter_params.Imax    %current limit, not using right now
                            %TODO: add in
 
 
%PWM stage
inverter_params.Teq = 0.01;    % sec
inverter_params.Ted = 0.01;    % sec
 
% inverter_params.Vdc
% inverter_params.VT
 
%coupling impedance - from thesis pg. 88
inverter_params.Rf = 0.004;    % per-unit
inverter_params.Xf = 0.05;      % per-unit         

% inf bus network
inverter_params.Xe=0.5;
inverter_params.ZL=0.5;
inverter_params.Vinf=480;
inverter_params.theta_inf = 0;

%% x0 starting states

% for infinite bus example 
% Vt=550, Vinf=480, so expect power flow from inv to inf bus
x0_bus_inf = [550 0 0 0 0 0]';

% for converter connected to infinite bus example 
x0_inv_infbus=[480 0 480 0 0 480 repmat(0,1,8) 480 0 480]';
%s1 s2 s3 s4 s5 IQcmd IPcmd s6(iq) s7(id) Ed Eq s8 s9 Vt Qg omega Pactual
    