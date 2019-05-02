function f = infBusNwk(Vt, Qg, Pactual, theta_conv, omega, Pline, Qline, params)
% Parameters
Ze=params.Xe;
ZL=params.ZL;
Vinf=params.Vinf;
theta_inf = params.theta_inf;

% Traditional transmission line power flow equations
% algebraic, nonlinear

X=ZL+Ze;

f=[    
    % 0 =
    Pactual - (Vt*Vinf*sin(theta_conv - theta_inf))/X - Pline;
    
    % 0 = 
    Qg -(Vt^2/X - Vt*Vinf*cos(theta_conv - theta_inf)/X) - Qline;
    
    % dtheta_conv/dt =
    omega;
];
end

