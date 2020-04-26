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
inverter_params.Vref = 480;         % volts            
inverter_params.Pref = 0;           % watts
inverter_params.omega_s = 1;        % per-unit 377;      % rad/s

%QV droop - values taken from Rama Thesis Table 5.1
% needed to obtain stable operation between converers when multiple
% converters connected to same bus
inverter_params.Rq = 0.00;   % per-unit
inverter_params.Rp = 0.05*100;  % per-unit

%Outer current loop - values taken from Rama paper Section B 
% gains
%Note: these need to be tuned a lot differentially the in the paper if not
%using limit / saturation blocks
inverter_params.Ki = 10;%1;%4.0; %(from thesis) %20.0;
inverter_params.Kp = 10;%1;%0.01; %(from thesis) %4.0;
inverter_params.Kiq = 0;%0.001;%0.0; %(from thesis pg. 75 - 10.0)
inverter_params.Kip = 10;%10;%4.0; %10.0;%(from thesis pg. 75 - 10.0)

% time constants
inverter_params.Tr = 0.02;  % sec, from Rama thesis Table 5.1
inverter_params.TGpv = 0.01; % sec, from Rama thesis Table 5.1
 
%inverter_params.Tfrq

%Inner current loop - real and reactive
inverter_params.Td = 0.01;     % sec
inverter_params.Tq = 0.01;     % sec

% inverter_params.Imax    %current limit, not using right now
                            %TODO: add in
 
 
%PWM stage
inverter_params.Teq = 0.01;    % sec
inverter_params.Ted = 0.01;    % sec
  
%coupling impedance - from thesis pg. 88
inverter_params.Rf = 0.004*100;    % per-unit
inverter_params.Xf = 0.05*100;      % per-unit         

% inf bus network
%inverter_params.Xe=0.5;
inverter_params.Zl=20j; % line impedance, should be totally reactive %0.5;
inverter_params.Sload = 100+100*j;  % load, complex
inverter_params.Vinf=480;
inverter_params.theta_inf = 0;  % radians

%% x0 starting states

% % for infinite bus example 
% % Vt=550, Vinf=480, so expect power flow from inv to inf bus
% % x0_bus_inf = [550 0 0 0 0 0]';

% for converter connected to infinite bus example 
%initial conditions
s1_0 = 0;
s2_0 = 480;
s3_0 = 0;
s4_0 = 0;
s5_0 = 0;
IQcmd_0 = 0;
IPcmd_0 = 0;
s6_0 = 100/(-480);%0;   % iq
s7_0 = 100/480; %0;   % id
Ed_0 = 480;
Eq_0 = 0;
s8_0 = 480;
s9_0 = 0;
%Pline_0 = 0;
%Qline_0 = 0;
theta_conv_0 = 0;
Qg_0 = 0;         %Qg_0 = 480;
Pactual_0 = 0;    %Pactual_0 = 0;
omega_0 = inverter_params.omega_s;
Vt_0 = 480;

Ed_star_0 = 480;
Eq_star_0 = 0;

x0_inv_infbus=[s1_0 s2_0 s3_0 s4_0 s5_0 IQcmd_0 IPcmd_0 s6_0 s7_0 Ed_0 Eq_0 s8_0 s9_0 Vt_0 theta_conv_0 Qg_0 Pactual_0 omega_0 Ed_star_0 Eq_star_0]';

inverter_params.Pnom = Pactual_0;

%x0_inv_infbus=[s1_0 s2_0 s3_0 s4_0 s5_0 IQcmd_0 IPcmd_0 s6_0 s7_0 Ed_0 Eq_0 s8_0 s9_0 Pline_0 Qline_0 theta_conv_0 Qg_0 Pactual_0 omega_0 Vt_0]';
%s1 s2 s3 s4 s5 IQcmd IPcmd s6(iq) s7(id) Ed Eq s8 s9 Pline Qline
%theta_conv  Qg Pactual omega Vt
    