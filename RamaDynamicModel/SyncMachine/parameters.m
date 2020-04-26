
%Params for the two-axis Syncronous Machine Model
%Values taken from synchronous machine 2 in table D.5 on page 526 of Milano
%(part of the IEEE 14-bus system presented there).
SM_params.bus = 1; %The location on a network, unused right now.
SM_params.MVApu = 60; %This is also the capacity
SM_params.H = 6.54/SM_params.MVApu; %Inertia constant, given in [MVA], converted to pu
SM_params.M = 2 * SM_params.H; %Machine starting time, equivalent to 2H (perhaps we should change to H to avoid confusion with the DAE mass matrix   
SM_params.D = 2; %Damping parameter
SM_params.W_s = 1; %The system reference frequency in p.u.
SM_params.freq_s = 60; %the system frequency in Hz
SM_params.v_f0 = 0.1; %Field voltage (should become a control input)
SM_params.P_m0= 0.9; %Mechanical Power (should become a control input)
SM_params.r_a = 0.0031; %armature resistance [pu]
%SM_params.x_t % Leakage Reactance
SM_params.x_d = 1.05; % d-axis synchronous reactance
SM_params.xprime_d = 0.185; % d-axis transient reactance
SM_params.x_q = 0.98; % q-axis synchronous reactance
SM_params.xprime_q = 0.36; % q-axis transient reactance
SM_params.Tprime_d0 = 6.1; %d-axis open circuit transient time constant [s]
SM_params.Tprime_q0 = 0.3; %q-axis open circuit transient time constant [s]
%SM_params.v_g = 1; %Initial Voltage magnitude of the generator as presented to the system (I believe this to be unneccessary)

%AVR number 2 from Milano, pg. 526
AVR_params.Vmax_r = 2.05; %pu
AVR_params.Vmin_r = 0; %pu
AVR_params.K_a = 20; %pu/pu
AVR_params.T_a = 0.02; %s
AVR_params.K_f = 0.001; % s pu/pu
AVR_params.T_f = 1; %s
AVR_params.K_e = 1; %pu
AVR_params.T_e = 1.98; %s
AVR_params.T_r = 0.001; %s
AVR_params.A_e = 0.0006; %no units
AVR_params.B_e = 0.9; %1/pu

%Governor Params from Milano for Machine #2, from table D.8
gov_params.R = 0.02;%pu
gov_params.T_s = 0.1;%s
gov_params.T_c = 0.45;%s
gov_params.T_3 = 0;%s
gov_params.T_4 = 0;%s
gov_params.T_5 = 50;%s
gov_params.Pmax = 1.2;%pu
gov_params.Pmin = 0.3;%pu
gov_params.W_ref = SM_params.W_s;



% T_AA %d-axis additional leakage time constant
% alpha_p %Active power ratio at node
% alpha_q %Reactive power ratio at node

InfBus_params.X = 0.5; %Reactance of the line to the infinte bus.
InfBus_params.W_s = SM_params.W_s;
InfBus_params.v_s = 1; %Initial Voltage magnitude of the system
InfBus_params.theta_s = 0; %Voltage angle of the infinite bus

