%% SynchMachine Parameters
Xl=0.5;
Xth=0.25;
Xg=0.25;
V1o=1;
V=1;
M=0.1;    
D=0.1;  
Pd=0.9;
Kv=10; 
Eo=1; 

%% Inverter Parameters
%Initial Conditions Inverter
x0=[
        1.02 ...   % 1: vod              - Steady state = v_ref
       -0.00074 ...% 2: voq              - From d_vod/dt = 0 and other inits
        0.5 ...    % 3: icvd             - Fig 13, D'Arco et al EPSR 122 (2015)
        0.0 ...    % 4: icvq             - Fig 13, D'Arco et al EPSR 122 (2015)
        0.005 ...  % 5: gamma_d          - Infer small from large gains
        0.001 ...  % 6: gamma_q          - Infer small from large gains
        0.49 ...   % 7: iod              - Fig 12, D'Arco at al EPES 72 (2015)
        0.075 ...  % 8: ioq              - From d_voq/dt = 0 and other inits //-0.132 is from Fig 12, D'Arco at al ESPR 72 (2015)
        1.02 ...   % 9: phi_d            - Infer from d_phi_d/dt = 0
       -0.10 ...   %10: phi_q            - Infer from d_phi_q/dt = 0
        1.004 ...  %11: vpll_d           - Infer from d_vpll_
        0 ...      %12: vpll_q           - Infer from d_epsilon_pll/dt = 0
       -0.0007 ... %13: epsilon_pll      - Infer from d_theta_pll/dt = 0; 1/(2*pi*50*4.69)
        0.2 ...    %14: delta_theta_vsm  - Fig 10, D'Arco et al, EPSR 122 (2015), "SmartGrids"
        0.0015 ... %15: xi_d             - Infer from d_gamma_d?/dt = 0
        1.2e-04... %16: xi_q             - Infer from d_gamma_q?/dt = 0
        0.025 ...  %17: qm               - Fig 11, D'Arco et al, EPSR 122 (2015), "SmartGrids"
        0 ...      %18: delta_w_vsm      - Should be near grid at op pt; Infer from d_delta_w_vsm/dt = 0
        0.1];      %19: delta_theta_pll  - Fig 10, D'Arco et al, EPSR 122 (2015), "SmartGrids"

%VSM Parameters
inverter_params.Ta = 2; % VSM Inertia constant 
inverter_params.kd = 0;%400; % VSM Damping co-efficient
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
inverter_params.kffv = 1; % Binary variable enabling the votlage feed-forward in output of current controllers
inverter_params.kffi = 0;