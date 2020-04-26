
function dxdt = testLCLcontrollers(t,x)

% INVERTER MODEL PARAMETERS with units

%k_p = 1; k_v = 1;   % scaling parameters

% PLL proportional-integral control gains
%k_PLLp = 0.25;      % rad/V
%k_PLLi = 2;         % rad/(V*s)

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
omega = 2*pi*60; % Hz
% unscaled real and reactive power set points
p_star = 500e6;     % MW
q_star = 50e6;      % MVAR
% unscaled grid voltage at point of interconnection
v_gd = 0;        % kV
v_gq = 24e3;     % 24kV
v_gdq = [v_gd, v_gq]';
%p_star = u(1); q_star = u(2); v_gdq = u(3);
%[p_star, q_star, v_gdq]' = u;

% dynamical states and inputs
i_1dq = x(1:2);     %i_1d = i_1dq(1); i_1q = i_1dq(2);   % filter current
i_odq = x(3:4);     %i_od = i_odq(1); i_oq = i_odq(2);   % terminal current
v_cdq = x(5:6);     %v_cd = v_cdq(1); v_cq = v_cdq(2);   % capacitor voltage
gamma_dq = x(7:8);  % states for current PI controller
p_avg = x(9);       % low-pass-filtered measurement of inverter real power
q_avg = x(10);      % low-pass-filtered measurement of inverter reactive power
phi_pq = x(11:12);  % states for real and reactive power controllers
%v_PLL = x(5);      % filtered d-axis voltage measurement
%phi_PLL = x(6);    % PI compensator state for PLL
%delta_i = x(7);    % angle for dq transformation
%delta_g = x(8);    % angle of grid

%[i_1dq, i_odq, v_odq, gamma_dq, p_avg, q_avg, phi_pq, v_PLL, phi_PLL, delta_i]' = x;

%% omega terms

omega_nom = omega; % Hz
omega_cPLL = 2*pi*250; % Hz
omega_c = 2*pi*250;
omega_PLL = omega_nom;


%% Controllers

% calculating v_odq from redefined state variable v_cdq
v_odq = (i_1dq - i_odq)*R_c + v_cdq;

% real power delivered by inverter
p = 3/2 * v_odq' * i_odq;                   %p = 3/2 * (v_od * i_od + v_oq * i_oq);
% reactive power delivered by inverter
q = 3/2 * v_odq' * [0, -1; 1, 0] * i_odq;   %q = 3/2 * (v_oq * i_od - v_od * i_oq);

% power controller dynamics
s_avg = [p_avg, q_avg]';                    % low-pass filtered measurements of inverter power
ds_avg = omega_c * ([p,q]' - s_avg);        dp_avg = ds_avg(1); dq_avg = ds_avg(2);
dphi_pq = [p_star, q_star]' - s_avg;        % difference between input signals and measurements

% current commands derived from power controller
i_1dqstar = k_PQp * dphi_pq + k_PQi * phi_pq; 
% i_1dqstar = [i_1dstar, i_1qstar]'; %i_odq = i_1dqstar;
%i_odq = (v_gdq - v_odq)/R_d; %i_odq = v_odq / R_d;

% this line removes the power controller
% when commented power controller is activated
% when uncommented only the current controller is activated
%i_1dqstar = [-24e3,0]';

% current controller:
dgamma_dq = i_1dqstar - i_1dq;
% current controller output, which yields switch terminal voltage:
v_idqstar = k_ip * dgamma_dq + k_ii * gamma_dq + [0, -1; 1, 0] * omega_PLL * L_f * i_1dq + v_odq;
%v_idqstar = [0,24e3]';

v_idq = v_idqstar; % assumption %v_id = v_idq(1); v_iq = v_idq(2);


%% LCL filter

%v_idq = v_gdq; %v_id = v_idq(1); v_iq = v_idq(2);

njomeg = [0 omega; -omega 0];

di_odq = njomeg*i_odq + 1/L_g * (v_cdq + (i_1dq - i_odq)*R_c - (v_gdq + i_odq*R_g));
di_1dq = njomeg*i_1dq + 1/L_f * (v_idq - i_1dq*R_f - v_cdq - (i_1dq - i_odq)*R_c);
dv_cdq = njomeg*v_cdq + (i_1dq - i_odq)/c;


dxdt = [di_1dq', di_odq', dv_cdq', dgamma_dq', dp_avg, dq_avg, dphi_pq']';
