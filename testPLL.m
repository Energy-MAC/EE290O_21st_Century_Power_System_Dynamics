
function dxdt = testPLL(t,x,u)

%% INVERTER MODEL PARAMETERS with units

%k_p = 1; k_v = 1;   % scaling parameters

% PLL proportional-integral control gains
k_PLLp = 0.25;      % rad/V
k_PLLi = 2;         % rad/(V*s)

% gains of the power controller
k_PQp = 0.01;       % V^-1
k_PQi = 0.1;        % (V*s)^-1

% compensator gains of the current controller
k_ip = 16.4;        % V/A
k_ii = 30.4;        % V/(A*s)

% LCL filter parameters
R_f = 0.7;          % ohm, resistance      %neglected
L_f = 1e-3;         % mH, inductance
R_g = 0.12;         % ohm, switched from R_o   %neglected      
L_g = 0.2e-3;       % mH, switched from L_o
R_c = 0.02;         %1/(1/R_f + 1/R_g) + 0.02 %0.02; % ohm
c = 24e-6;          % muF

% parameters from case study
% unscaled real and reactive power set points
%p_star = 0;     %500e6;     % MW
%q_star = 5.2e6; %50e6;      % MVAR
% unscaled grid voltage at point of interconnection
%v_gd = 24e3;        % 24 kV
%v_gq = 0;           % kV
%v_gdq = [v_gd, v_gq]';
%p_star = u(1); q_star = u(2); v_gdq = u(3);
%[p_star, q_star, v_gdq]' = u;

%% dynamical states and inputs

%i_1dq = x(1:2);     i_1d = i_1dq(1); i_1q = i_1dq(2);   % filter current
%i_odq = x(3:4);     i_od = i_odq(1); i_oq = i_odq(2);   % terminal current
%v_odq = x(5:6);     v_od = v_odq(1); v_oq = v_odq(2);   % filter voltage
%gamma_dq = x(7:8);  % states for current PI controller
%p_avg = x(9);       % low-pass-filtered measurement of inverter real power
%q_avg = x(10);      % low-pass-filtered measurement of inverter reactive power
%phi_pq = x(11:12);  % states for real and reactive power controllers
v_PLL = x(1);      % filtered d-axis voltage measurement
phi_PLL = x(2);    % PI compensator state for PLL
delta_i = x(3);    % angle for dq transformation
delta_g = x(4);    % angle of grid

%[i_1dq, i_odq, v_odq, gamma_dq, p_avg, q_avg, phi_pq, v_PLL, phi_PLL, delta_i]' = x;

%% PLL dynamics

omega = 2*pi*60; % Hz
omega_nom = omega; % Hz
omega_cPLL = 2*pi*250; % Hz, where omega_cPLL is cutoff frequency of filter
omega_c = 2*pi*250; %

ddelta_g = 377;
v_od = 24000*cos(delta_g-delta_i); % filter voltage
% v_PLL = v_od - v_PLL' where v_PLL' is the voltage inside the PLL

dv_PLL = omega_cPLL * (v_od - v_PLL);
dphi_PLL = -v_PLL;
ddelta_i = omega_nom - k_PLLp * v_PLL + k_PLLi * phi_PLL;
omega_PLL = ddelta_i;

dxdt = [dv_PLL, dphi_PLL, ddelta_i, ddelta_g]';