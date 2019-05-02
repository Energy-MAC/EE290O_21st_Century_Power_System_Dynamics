%Params for the two-axis Syncronous Machine Model
SM_params.bus = 1; %The location on a network, unused right now.
SM_params.M=0.1; %Machine starting time, equivalent to 2H (perhaps we should change to H to avoid confusion with the DAE mass matrix   
SM_params.D=0.4; %Damping parameter
SM_params.v_g = 1; %Initial Voltage magnitude of the generator as presented to the system
SM_params.v_s = 1; %Initial Voltage magnitude of the system
SM_params.X = 0.5; %Reactance of the line to the infinte bus.
SM_params.W_s = 1; %The system reference frequency in p.u.
SM_params.theta_s = 0; %Voltage angle of the infinite bus
SM_params.freq_s = 60; %the system frequency in Hz
%SM_params.v_f = 0.1; %Field voltage (should become a control input)
SM_params.P_m=1.0; %Mechanical Power (should become a control input)
% H %Inertia constant [MVA]
% r_a %armature resistance [pu]
% x_t % Leakage Reactance
% x_d % d-axis synchronous reactance
% xprime_d % d-axis transient reactance
% x_q % q-axis synchronous reactance
% xprime_q % q-axis transient reactance
% T_AA %d-axis additional leakage time constant
% Tprime_d0 %d-axis open circuit transient time constant
% Tprime_q0 %q-axis open circuit transient time constant
% alpha_p %Active power ratio at node
% alpha_q %Reactive power ratio at node



% params from GE tutorial manual
% Modeling of GE Solar PV plans for grid studies (Apr 2010)
% http://files.engineering.com/download.aspx?folder=72244e74-9cb5-4d18-8ce1-e25fd1b01866&file=GE_Solar_Modeling-v1-1.pdf
% "The aggergate solar plant is modeled as a conventional generator
% connected to a 480V bus. The generator real power output (Pgen), Qmin,
% and Qmax should match the solar plant capability

% Table 2-1 overallInverter rating
% Use for load flow, which initializes dynamic sim
% inverter_params.Pmax=700; % kW
% inverter_params.Pmin=0; % kW
% inverter_params.Qmax=99 % kVar, for 0.99 pow factor
% inverter_params.Qmin=-99 % kVar
inverter_params.Pord=500; % arbitrary, user-written solar pow profile


% QV droop
inverter_params.Tr=0.02; % sec, vmeas lag
inverter_params.Tv=0.05; % sec
inverter_params.Tc=0.15; % sec, cycle time + comm delay + control filtering
inverter_params.Vfrz=0.7; % not used for now
inverter_params.Kpv=18; % QVdroop coeff, prop
inverter_params.Kiv=5;
inverter_params.Qmax=0.14; % pu
inverter_params.Qmin=-0.14; % pu
inverter_params.Tpwr=0.05; % sec, unsure what this is used for

% Current control
inverter_params.Kqi=0.1;
inverter_params.Kvi=120;
% Sat block:
% Vmax=1.1
% Vmin=0.9
% pqflag=0 (Q priority)
% Current limiter block: these vals are some function of Iqhl and Iphl
% Iqmin=
% Iqmax=
% Ipmax=

inverter_params.Tpwm=0.02 % for PWM switching
inverter_params.Khv=1; %  fow now, not used
inverter_params.Klv=1; % for now, not used
%inverter_params.K_LPVL=

% inf bus network
inverter_params.Xe=0.05;
inverter_params.ZL=0.05;
inverter_params.Vinf=480;
inverter_params.theta_inf=0;

%-------------------------------------
% Turn controller gains off:
inverter_params.Kpv=0;
inverter_params.Kiv=0;
inverter_params.Kqi=0;
inverter_params.Kvi=0;

% boundaryinv_infBus
 x0_test1=[480 0 480 0 0 480 repmat(0,1,8) 480 0 480]';

%bound_infSimple
x0_test2=[480 0 0 0 0 0]';

