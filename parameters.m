%% SynchMachine Parameters
% Electrical Parameters of Machine 1, Milano's Book Page 526
machine_params.Xl=0.2396;
machine_params.Xd=0.8979;
machine_params.Xq=0.646;
machine_params.Xd_p=0.2995;
machine_params.Xq_p=0.646;
machine_params.Xd_pp=0.23;
machine_params.Xq_pp=0.4;

machine_params.Td0_p=7.4;
machine_params.Td0_pp=0.03;
machine_params.Tq0_p=0.0;
machine_params.Tq0_pp=0.033;

% Mechanical Parameters
machine_params.H=5.148;    
machine_params.D=2;  
machine_params.Pd=0.4;
machine_params.tvar_fun = @default;
machine_params.MVABase = 615;

AVR_params.Kv = 200; %Page 526
AVR_params.V_sp = 1.05;

%% Inf bus parameters 
S=readcf('OMIB.cf'); %This Function ONLY reads the information stored on the *cf file 
infbus_params.Xth = 0.00;
infbus_params.V_inf = S.Bus.Voltages(1);
infbus_params.Theta_inf = 0.0;
infbus_params.SystemBaseMVA = S.BaseMVA;

%% Line parameters 
line_params.Xl = imag(S.Branch.Z);

%% Inverter Parameters
%VSM Parameters
inverter_params.Ta = 2; % VSM Inertia constant 
inverter_params.kd = 400; % VSM Damping co-efficient
inverter_params.kw = 20; % Frequency droop gain in p.u.
inverter_params.p_ref = 0.5; % Active power reference in p.u.
inverter_params.w_ref = 1; %Inverter frequency set point in p.u.

inverter_params.v_rated = 690; % Rated Voltage
inverter_params.s_rated = 2.75e6; % Rated power
inverter_params.BaseMVA = inverter_params.s_rated/1e6;
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

inverter_params.tvar_fun = @default;

%Initial Conditions Inverter
x0=[
    0 ...       % 1: delta_w_vsm      - Should be near grid at op pt; Infer from d_delta_w_vsm/dt = 0
    0.2 ...     % 2: delta_theta_vsm  - Fig 10, D'Arco et al, EPSR 122 (2015), "SmartGrids"
    ...
    0.95 ...    % 3: vod              - Fig 8 or 10c, D'Arco at al EPES 72 (2015), but at steady state = v_ref?
   -0.1 ...     % 4: voq              - Infer from d_vpll_q/dt = 0, i.e. -vod*tan(0.1) w/ vod ~ 1; or power flow?
    0.5 ...     % 5: icvd             - Fig 13, D'Arco et al EPSR 122 (2015)
    0.0 ...     % 6: icvq             - Fig 13, D'Arco et al EPSR 122 (2015)
    0.0015 ...  % 7: xi_d             - Infer from d_gamma_d/dt = 0
   -0.07 ...    % 8: xi_q             - Infer from d_gamma_q/dt = 0
    ...
    0.005 ...   % 9: gamma_d          - Infer small from large gains
   -0.001 ...   %10: gamma_q          - Infer small from large gains
    0.49 ...    %11: iod              - Fig 12, D'Arco at al EPES 72 (2015)
   -0.1 ...     %12: ioq              - Fig 12, D'Arco at al ESPR 72 (2015)
    0.95 ...    %13: phi_d            - Infer from d_phi_d/dt = 0; Guess close to vod
   -0.10 ...    %14: phi_q            - Infer from d_phi_q/dt = 0; Guess close to -voq
    ...
    1.004 ...   %15: vpll_d           - Infer from d_pll_d = 0; vod*cos(0.1)+voq*sin(0.1)
    0 ...       %16: vpll_q           - Infer from d_epsilon_pll/dt = 0
    0 ...       %17: epsilon_pll      - Infer from d_delta_theta_pll/dt = 0
    0.1 ...     %18: delta_theta_pll  - Fig 10, D'Arco et al, EPSR 122 (2015), "SmartGrids"
    ...
    0.025       %19: qm               - Fig 11, D'Arco et al, EPSR 122 (2015), "SmartGrids"
    ];

function params_out = default(t,params_in)
    params_out = params_in;
end