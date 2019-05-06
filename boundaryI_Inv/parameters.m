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
%inverter_params.Pord=500; % arbitrary, user-written solar pow profile


% QV droop
inverter_params.Tr=0.02; % sec, vmeas lag
inverter_params.Tv=0.05; % sec
inverter_params.Tc=0.15; % sec, cycle time + comm delay + control filtering
inverter_params.Vfrz=0.7; % not used for now
inverter_params.Kpv=1; % originally 18, QVdroop coeff, prop
inverter_params.Kiv=0.1; % originally 5
% inverter_params.Qmax=0.14; % originally 0.14pu
% inverter_params.Qmin=-0.14; % pu

% Current control
inverter_params.Kqi=0.05; % originally 0.1
inverter_params.Kvi=1; % originally 120, causing blowup
inverter_params.Tfrq=0.1; % DUNNO
inverter_params.Kw=100; % 1/0.5 typical Pf droop control gain, from Rama thesis ch 3.2
inverter_params.ws=1; % pu, from Rama thesis ch 3.2

% Sat block:
% Vmax=1.1
% Vmin=0.9
% pqflag=0 (Q priority)
% Current limiter block: these vals are some function of Iqhl and Iphl
% Iqmin=
% Iqmax=
% Ipmax=

inverter_params.Tpwm=0.02 % for PWM switching
%inverter_params.K_LPVL=

% inf bus network
% Note: line impedance usually much smaller than load impedance
inverter_params.Zl=1; % line impedance
inverter_params.ZL=100+1*j; % load, complex

inverter_params.Vinf=480
inverter_params.theta_inf=0; % radians

%-------------------------------------
% % Turn controller gains off:
%inverter_params.Kpv=0;
%inverter_params.Kiv=0;
% inverter_params.Kqi=0;
% inverter_params.Kvi=0;
% inverter_params.Kw=10000000; % make large to "turnoff" P-f loop
% 

% boundaryinv_infBus
 %x0_test1=[480 0 480 0 0 480 repmat(0,1,8) 550 0 480]';
 %x0_test1=[480 0 0 0 480 repmat(0,1,8) 480 0 480]';
% varType=[V Q Q Q V I I I I I I P Q V theta V]
% extended to 20 states with freq control 

% Vinf/(1+Zl/ZL) % is complex, so take mag and phase for init cond
a=inverter_params.Vinf/(1+inverter_params.Zl/inverter_params.ZL);
Vterm_theta0=angle(a)% no freq dev
Vterm0=abs(a) % Vref set as this
inverter_params.Ipmax=inverter_params.Pmax/Vterm0; % limit in phys conv block
inverter_params.Iqmax=inverter_params.Qmax/Vterm0; % limit in phys conv block
inverter_params.Ipmin=inverter_params.Pmin/Vterm0; % limit in phys conv block
inverter_params.Iqmin=inverter_params.Qmin/Vterm0; % limit in phys conv block

Pt0=0-Vterm0^2/real(inverter_params.ZL)
Qt0=0-Vterm0^2/imag(inverter_params.ZL)
w0=inverter_params.ws;
x0_test1=[Vterm0 0 0 0 Vterm0 0 0 w0 0 repmat(0,1,4) Vterm0 Vterm_theta0 Pt0 Qt0 Vterm0]';
% varType=[V Q Q Q V I I w P I I I I V theta P Q V], theta is in radia ns



%bound_infSimple
x0_test2=[550 0 0 0 0 0]';
% Vt=550, Vinf=480, so expect power flow from inv to inf bus

