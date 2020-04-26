
function dxdt = testLCL(t,x)

% INVERTER MODEL PARAMETERS with units

%k_p = 1; k_v = 1;   % scaling parameters

% PLL proportional-integral control gains
%k_PLLp = 0.25;      % rad/V
%k_PLLi = 2;         % rad/(V*s)

% gains of the power controller
%k_PQp = 0.01;       % V^-1
%k_PQi = 0.1;        % (V*s)^-1

% compensator gains of the current controller
%k_ip = 16.4;        % V/A
%k_ii = 30.4;        % V/(A*s)

% LCL filter parameters
R_f = 0.7;          % ohm, resistance
L_f = 1e-3;         % mH, inductance
R_g = 0.12;         % ohm, switched from R_o
L_g = 0.2e-3;       % mH, switched from L_o
R_c = 0.02;         % ohm
c = 24e-6;          % muF

% parameters from case study
omega = 2*pi*60; % Hz
% unscaled real and reactive power set points
p_star = 0;     %500e6;     % MW
q_star = 5.2e6; %50e6;      % MVAR
% unscaled grid voltage at point of interconnection
v_gd = 0;        % kV
v_gq = 24e3;     % 24kV
v_gdq = [v_gd, v_gq]';
%p_star = u(1); q_star = u(2); v_gdq = u(3);
%[p_star, q_star, v_gdq]' = u;

% dynamical states and inputs
i_1dq = x(1:2);     i_1d = i_1dq(1); i_1q = i_1dq(2);   % filter current
i_odq = x(3:4);     i_od = i_odq(1); i_oq = i_odq(2);   % terminal current
v_cdq = x(5:6);     v_cd = v_cdq(1); v_cq = v_cdq(2);   % filter voltage
%gamma_dq = x(7:8);  % states for current PI controller
%p_avg = x(1);       % low-pass-filtered measurement of inverter real power
%q_avg = x(2);      % low-pass-filtered measurement of inverter reactive power
%phi_pq = x(3:4);  % states for real and reactive power controllers
%v_PLL = x(5);      % filtered d-axis voltage measurement
%phi_PLL = x(6);    % PI compensator state for PLL
%delta_i = x(7);    % angle for dq transformation
%delta_g = x(8);    % angle of grid

%[i_1dq, i_odq, v_odq, gamma_dq, p_avg, q_avg, phi_pq, v_PLL, phi_PLL, delta_i]' = x;

%% LCL filter

v_idq = v_gdq;
v_id = v_idq(1); v_iq = v_idq(2);

njomeg = [0 omega; -omega 0];

di_odq = njomeg*i_odq + 1/L_g * (v_cdq + (i_1dq - i_odq)*R_c - (v_gdq + i_odq*R_g));
di_1dq = njomeg*i_1dq + 1/L_f * (v_idq - i_1dq*R_f - v_cdq - (i_1dq - i_odq)*R_c);
dv_cdq = njomeg*v_cdq + (i_1dq - i_odq)/c;

%di_od = 1/L_g * (L_g*omega*i_oq + v_od - (i_1d-i_od)*R_c - v_gd - R_c*i_od + R_c*i_1d);
%di_oq = 1/L_g * (-L_g*omega*i_od + v_oq - (i_1q-i_oq)*R_c - v_gq - R_c*i_oq + R_c*i_1q);
%di_odq = [di_od, di_oq];

%di_1d = 1/L_f * (L_f*omega*i_1q - (v_od - (i_1d-i_od)*R_c) + v_id + R_c*i_od - R_c*i_1d);
%di_1q = 1/L_f * (-L_f*omega*i_1d - (v_oq - (i_1q-i_oq)*R_c) + v_iq + R_c*i_oq - R_c*i_1q);
%di_1dq = [di_1d, di_1q];

%dv_od = 1/c * (c*R_c*(di_1d-di_od) + c*omega*(v_oq - (i_1q-i_oq)*R_c) - i_od + i_1d);
%dv_oq = 1/c * (c*R_c*(di_1q-di_oq) - c*omega*(v_od - (i_1d-i_od)*R_c) - i_od - i_1d);
%dv_odq = [dv_od, dv_oq];

dxdt = [di_1dq', di_odq', dv_cdq']';