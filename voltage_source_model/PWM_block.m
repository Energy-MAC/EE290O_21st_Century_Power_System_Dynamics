% M-file accepts two arguments: t and y
% returns column vector dy


function dy = PWM_block(,  params)
% Inputs, outputs, and params of state space rep:
    % Inputs:  Ed, Eq, Vdc, VT
    % States: 
    % Outputs: 
   
% -----------------------------------------------

%get reference parameters

%initialized values:
VT = sqrt(Ed^2 + Eq^2)/0.6;
Vdc = sqrt(Ed^2 + Eq^2)/(0.5*0.6);

mag_E = sqrt(Ed^2 + Eq^2);
phi_E = arctan(Eq/Ed);

m = mag_E/VT;   %should be limited between 0.4 and 1.0

Ea = 0.5*m*Vdc*cos(omega_s*t+phi_E);
Eb = 0.5*m*Vdc*cos(omega_s*t+phi_E-120);
Ec = 0.5*m*Vdc*cos(omega_s*t+phi_E-240);


dy = [
    %%% Differential equations:
    
    

];
