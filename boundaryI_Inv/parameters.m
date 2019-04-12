% params from GE tutorial manual
% Modeling of GE Solar PV plans for grid studies (Apr 2010)
% http://files.engineering.com/download.aspx?folder=72244e74-9cb5-4d18-8ce1-e25fd1b01866&file=GE_Solar_Modeling-v1-1.pdf


% "The aggergate solar plant is modeled as a conventional generator
% connected to a 480V bus. The generator real power output (Pgen), Qmin,
% and Qmax should match the solar plant capability

% Table 2-1 overallInverter rating
% Use for load flow, which initializes dynamic sim
inverter_params.Pmax=700; % kW
inverter_params.Pmin=0; % kW
inverter_params.Qmax=99 % kVar, for 0.99 pow factor
inverter_params.Qmin=-99 % kVar
inverter_params.Vref=480; % V
inverter_params.Vmeas=480; % TEMP
inverter_params.Pord=500 % arbitrary, user-written solar pow profile


% QV droop
inverter_params.Tr=0.02 % sec, vmeas lag
inverter_params.Tv=0.05 % sec
inverter_params.Tc=0.15 % sec, cycle time + comm delay + control filtering
inverter_params.Vfrz=0.7 % not used for now
inverter_params.Kpv=18 % QVdroop coeff, prop
inverter_params.Kiv=5
inverter_params.Qmax=0.14 % pu
inverter_params.Qmin=-0.14 % pu
inverter_params.Tpwr=0.05 % sec, unsure what this is used for

% Current control
inverter_params.Kqi=0.1
inverter_params.Kvi=120
% Sat block:
% Vmax=1.1
% Vmin=0.9
% pqflag=0 (Q priority)
% Current limiter block: these vals are some function of Iqhl and Iphl
% Iqmin=
% Iqmax=
% Ipmax=

inverter_params.Tpwm=0.02 % for PWM switching
inverter_params.Khv=1; %  fow now, 
inverter_params.Klv=1; % for now, 
%inverter_params.K_LPVL=

% inf bus network
inverter_params.Xe=0.1;
inverter_params.ZL=0.1;
inverter_params.Vinf=480;
inverter_params.theta_inf=0;

 %x0=zeros(17,1) % TEMP
% x0(4)=480; x0(6)=480;

% Simple:
x0=[480 0 0 0 0 0]';

