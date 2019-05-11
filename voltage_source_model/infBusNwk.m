function f = infBusNwk(Vt, theta_conv, omega, Qg, Pactual, x_inner_curr_loop, params)
% Parameters
Ze=params.Xe;
ZL=params.ZL;
Vinf=params.Vinf;
theta_inf = params.theta_inf;
omega_s = params.omega_s;

% Traditional transmission line power flow equations
% algebraic, nonlinear

X=ZL+Ze;

iq = x_inner_curr_loop(1);  % s6 = iq
id = x_inner_curr_loop(2);  % s7 = id
 
Vtd = Vt*cos(theta_conv);
Vtq = Vt*sin(theta_conv); 
 
% Qg = Vtq*id - Vtd*iq;
% Pactual = Vtd*id + Vtq*iq;

f=[    
    % Solves for Vt, theta_conv
    % 0 =
    % old: %Pactual - (Vt*Vinf*sin(theta_conv - theta_inf))/X - Pline;
    (Vt*Vinf*sin(theta_conv - theta_inf))/X - Pactual;  

    % Solves for Vt, theta_conv
    % 0 = 
    % old :%Qg - (Vt^2/X - Vt*Vinf*cos(theta_conv - theta_inf)/X) - Qline;
    (Vt^2/X - Vt*Vinf*cos(theta_conv - theta_inf)/X) - Qg;
    
    % how do I add this in? 
    % dtheta_conv/dt =
    %377*(omega - omega_s);
    
    % Solves for Qg
    % 0 = 
    Vtq*id - Vtd*iq - Qg;
    
    % Solves for Pactual
    % 0 = 
    Vtd*id + Vtq*iq - Pactual;
    
    % domega/dt =
    0;    
    
];
end

