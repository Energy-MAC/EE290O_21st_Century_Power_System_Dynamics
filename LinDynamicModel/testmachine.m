function dxdt = testmachine(t,x)

% MACHINE MODEL
% Milano sec. 15.1.3, 15.1.6 (classical model)

% parameters
omega = 2*pi*60; % Hz, frequency
omega_g = 1;     % p.u. reference grid frequency

H = 2.9;        % s, machine starting time
D = 10;          % p.u., damping coefficient of oscillations in rotor angle and frequency
X = 0.5;        % impedance of the machine
v_g = 1;        % p.u., grid voltage
theta_g = 0;    % voltage angle of the system (infinite bus, or bus from inverter)
p_m = 1;        % 555e6; % MVA
v_m = 1;        % 24e3; % kV, voltage of the machine

% dynamical states and inputs
delta_m = x(1); % machine rotor angle
omega_m = x(2); % want this to be equal to 1
p_e = x(3);     % power transfer
%u_m = [P_agc, v_star, i_mdq]';

ddelta_m = omega*(omega_m - omega_g);
domega_m = 1/(2*H) * (p_m - p_e - D*(omega_m - omega_g));
% p_e = (v_m*v_g)/X * sin(delta_m - theta_g);

dxdt = [ddelta_m, domega_m, (3*(v_m*v_g)/X * sin(delta_m - theta_g) - p_e)]';
