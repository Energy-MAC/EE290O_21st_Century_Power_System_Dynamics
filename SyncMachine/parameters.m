
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


% T_AA %d-axis additional leakage time constant
% alpha_p %Active power ratio at node
% alpha_q %Reactive power ratio at node

InfBus_params.X = 0.5; %Reactance of the line to the infinte bus.
InfBus_params.W_s = SM_params.W_s;
InfBus_params.v_s = 1; %Initial Voltage magnitude of the system
InfBus_params.theta_s = 0; %Voltage angle of the infinite bus

