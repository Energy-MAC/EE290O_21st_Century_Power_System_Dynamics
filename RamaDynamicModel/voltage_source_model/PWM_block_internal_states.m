function dy = PWM_block_internal_states(t, x_pwm_sw, omega, Ed_star, Eq_star, params)
% Inputs, outputs, and params of state space rep:
% Inputs:  Ed, Eq, Vdc, VT
% States: 
% Outputs: 

s8 = x_pwm_sw(1);  % s8 = delayed Eq
s9 = x_pwm_sw(2);  % s9 = delayed Ed

%get reference parameters
omega_s = params.omega_s;

%initialized values:
VT = sqrt(s8^2 + s9^2)/0.6;
Vdc = sqrt(s8^2 + s9^2)/(0.5*0.6);

mag_E = sqrt(s8^2 + s9^2);
phi_E = atan(s9/s8);

m = mag_E/VT;   %should be limited between 0.4 and 1.0

Ea = 0.5*m*Vdc*cos(omega_s*t+phi_E);
Eb = 0.5*m*Vdc*cos(omega_s*t+phi_E-2*pi/3);
Ec = 0.5*m*Vdc*cos(omega_s*t+phi_E-4*pi/3);

% Use Park's transformation on Ea, Eb, and Ec to get Ed_star and Eq_star

% see: https://www.mathworks.com/help/physmod/sps/powersys/ref/abctodq0dq0toabc.html

% when rotating frame is aligned 90 degrees behind A axis (not using this
% one)
% P = (2/3)* | sin(wt)  sin(wt-2pi/3)   sin(wt+2pi/3) |
%            | cos(wt)  cos(wt-2*pi/3)  cos(wt+2pi/3) |
%            | 1/2      1/2             1/2           |

% when rotating frame is aligned with A axis: 
% P = (2/3)* | cos(wt)   cos(wt-2pi/3)    cos(wt+2pi/3)  |
%            | -sin(wt)  -sin(wt-2*pi/3)  -sin(wt+2pi/3) |
%            | 1/2       1/2              1/2            |


dy = [
    
    %%% Algebraic Equations: 

    % Solves for Ed_star
    % 0 = 
    (2/3)*(cos(omega*t)*Ea + cos(omega*t - 2*pi/3)*Eb + cos(omega*t + 2*pi/3)*Ec) - Ed_star;

    % Solves for Eq_star
    % 0 = 
    (2/3)*(-sin(omega*t)*Ea - sin(omega*t - 2*pi/3)*Eb - sin(omega*t + 2*pi/3)*Ec) - Eq_star;
    
    ];


end
