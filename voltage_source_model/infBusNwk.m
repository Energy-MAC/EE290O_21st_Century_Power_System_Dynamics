function f = infBusNwk(Vt, Qg, omega, Pactual)
% Parameters
Ze=params.Xe;
ZL=params.ZL;
Vinf=params.Vinf;
theta_inf = params.theta_inf;

% States - Vt, Qg, omega, Pactual


% Traditional transmission line power flow equations
% algebraic, nonlinear

X=ZL+Ze;

f=[    
    (Ipterm*Vterm)-Vterm*Vinf*sin(Vterm_theta-theta_inf)/X-Pline;
    (Iqterm*Vterm)-(Vterm^2/X-Vterm*Vinf*cos(Vterm_theta-theta_inf)/X)-Qline;  
];
end

