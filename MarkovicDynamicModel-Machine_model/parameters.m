%% SynchMachine Parameters
gen.Xg=0.25;
gen.M=0.1;    
gen.D=0.1;  
gen.Pd=0.9;
gen.V0=1.1;

AVR.Kv=10; 
AVR.E0=1; 
AVR.V_sp=1;

%% Inf bus parameters 
infbus.Xth = 0.25;
infbus.V_inf = 1.0;
infbus.Theta_inf = 0.0;

%%Line parameters 
line.Xl = 0.5;

%% Inverter Parameters
%Initial Conditions Inverter
x0_inverter=[1, 0, 0.5, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0.2, 1, 1, 0.025,0, 0.1];

%VSM Parameters
inverter_params.Ta = 2; % VSM Inertia constant 
inverter_params.kd = 400; % VSM Damping co-efficient
inverter_params.kw = 20; % Frequency droop gain in p.u.
inverter_params.p_ref = 0.5; % Active power reference in p.u.
inverter_params.w_ref = 1; %Inverter frequency set point in p.u.

inverter_params.v_rated = 690; % Rated Voltage
inverter_params.s_rated = 2.75e6; % Rated power
inverter_params.wb = 2*pi*50; % Rated angular frequency
inverter_params.w_ref = 1; %Inverter frequency set point in p.u.
inverter_params.wg = 1; % Grid frequency in p.u.


inverter_params.kpc = 1.27; % Current controller gain
inverter_params.kic = 14.3; % Current controller gain

inverter_params.kpv = 0.59; % Voltage controller gain
inverter_params.kiv = 736; % Voltage controller gain


inverter_params.q_ref = 0; % Reactive power reference in p.u. 
inverter_params.kq = 0.2; % Reactive power droop gain in p.u.
inverter_params.wf = 1000; %Reactive power filter in rad/s
inverter_params.v_ref = 1.02; % Votlage referencfe in p.u. 
inverter_params.lf = 0.08; % Filter inductance in p.u.
inverter_params.rf = 0.003; % Filter resistance in p.u.
inverter_params.cf = 0.074; % Filter capacitance in p.u.
inverter_params.lg = 0.2; % Grid inductance in p.u.
inverter_params.rg = 0.01; % Grid resistance in p.u.
inverter_params.vg = 1.0; % Grid voltage in p.u. 
inverter_params.wad = 50; % Active damping filter
inverter_params.kad = 0.5; % Active damping gain 
inverter_params.lv = 0.2; % Virtual Inductance in p.u.
inverter_params.rv = 0; % Virtual resistance in p.u.
inverter_params.wlp = 500; % PLL filter in rad/s
inverter_params.kp_pll = 0.084; % PLL proportional gain
inverter_params.ki_pll = 4.69; % PLL integraql gain 
inverter_params.kffv = 0; % Binary variable enabling the votlage feed-forward in output of current controllers
inverter_params.kffi = 0;