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

%inputs
inverter_params.Vt
inverter_params.Qg
inverter_params.omega
inverter_params.Pactual

%intermediate outputs
inverter_params.Qcmd
inverter_params.Pcmd

%limits
%should set to limits as described on pg. 45 in rama thesis
inverter_params.Pmax = 700; % kW
inverter_params.Qmax = 99;  % kVar, for 0.99 power factor
inverter_params.Qmin = -99; % kVar

%reference points
inverter_params.Vref = 480; % V
inverter_params.Pref
inverter_params.omega_s = 377;   % rad/s
%QV droop (is this right?)
% needed to obtain stable operation between converers when multiple
% converters connected to same bus
inverter_params.Rq
inverter_params.Rp

%Outer current loop
    %reactive power controller
inverter_params.Ki
inverter_params.Kp
inverter_params.Kiq
inverter_params.Tr

    %real power controller
inverter_params.Tfrq
inverter_params.TGpv
inverter_params.Kip

%outputs from power controller (inputs to inner current loop)
inverter_params.Iqcmd
inverter_params.Ipcmd


%Inner current loop - real and reactive
inverter_params.Td
inverter_params.Tq
inverter_params.Imax    %current limit


%PWM stage
inverter_params.Teq
inverter_params.Ted

inverter_params.Vdc
inverter_params.VT

%coupling impedance
inverter_params.Rf
inverter_params.Xf

% inf bus network
inverter_params.Xe=0.1;
inverter_params.ZL=0.1;
inverter_params.Vinf=1000;

%need to set x0?

    