% parameters2.m has slightly modified params for 5bus+inv network
% parameter.m has inf bus params
%---------------------------------
% "The aggergate solar plant is modeled as a conventional generator
% connected to a 480V bus. The generator real power output (Pgen), Qmin,
% and Qmax should match the solar plant capability

% Table 2-1 overallInverter rating
% Use for load flow, which initializes dynamic sim
inverter_params.Pmax=700; % kW
inverter_params.Pmin=0; % kW
inverter_params.Qmax=99 % kVar, for 0.99 pow factor
inverter_params.Qmin=-99 % kVar
%inverter_params.Pord=500; % arbitrary, user-written solar pow profile

% QV droop
inverter_params.Tr=0.02; % sec, vmeas delay
inverter_params.Tv=0.05; % sec, delay with prop term in QV droop
inverter_params.Tc=0.15; % sec, cycle time + comm delay + control filtering
inverter_params.Vfrz=0.7; % not used for now
inverter_params.Kpv=70; % originally 18, QVdroop coeff, prop
inverter_params.Kiv=50; % originally 5
% inverter_params.Qmax=0.14; % originally 0.14pu
% inverter_params.Qmin=-0.14; % pu

% Current control
% inverter_params.Kqi=0.1; % originally 0.1
% inverter_params.Kvi=120; % originally 120, causing blowup
inverter_params.Tfrq=0.1; % DUNNO
inverter_params.Kwi=-2; % 2 typical Pf droop control gain, from Rama thesis ch 3.2
%inverter_params.ws=1; % pu, from Rama thesis ch 3.2
inverter_params.kphi=60; % associated with 60Hz, see equations for derivation
% Sat block:
% Vmax=1.1
% Vmin=0.9
% pqflag=0 (Q priority)
% Current limiter block: these vals are some function of Iqhl and Iphl
% Iqmin=
% Iqmax=
% Ipmax=

inverter_params.Tpwm=0.02 % for PWM switching time const
%inverter_params.K_LPVL=

%-------------------------------------
% % Turn controller gains off:
inverter_params.Kpv=0;
inverter_params.Kiv=0;
inverter_params.Kwi=0; % make large to "turnoff" P-f loop

%------------------------------------
% may not be used in phys converter block
inverter_params.Ipmax=inverter_params.Pmax/vmag_inv; % limit in phys conv block
inverter_params.Iqmax=inverter_params.Qmax/vmag_inv; % limit in phys conv block
inverter_params.Ipmin=inverter_params.Pmin/vmag_inv; % limit in phys conv block
inverter_params.Iqmin=inverter_params.Qmin/vmag_inv; % limit in phys conv block


inverter_params.Pnom=Pt0;
Vref=vmag_inv;
% inverter_params.Vterm_theta_ref=Vterm_theta0;
w0=1; % temp, not used
x0_inv=[Vref 0 0 0 0 0 w0 0 repmat(0,1,4) Vref 0 0 0 Vref]';
% varType=[V Q Q Q I I w P I I I I V theta P Q V], theta is in radia ns
