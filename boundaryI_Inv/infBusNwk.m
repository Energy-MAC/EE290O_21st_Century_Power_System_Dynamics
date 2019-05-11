% Network desc:
% Network has two buses, Vt and Vinf, separated by line Zl
% Vt has generator (inv) and constant impedance load, ZL
% Reference: Callaway ERG294 Notes, Lecv 15, virtual pg 210, see Example
% 10.3 too

function f = infBusNwk(Ipterm,Iqterm,Vterm, Vterm_theta,Pt,Qt,params)
% Params
 Zl=params.Zl; % line reactance
 Sload=params.Sload; % load, complex
 Vinf=params.Vinf;
 theta_inf = params.theta_inf;

% NOTE: DO NOT USE PHASOR REP FOR PF EQUATIONS,doesnt work

% Transmission line power flow equations between Vt and Vinf
% algebraic, nonlinear
X=imag(Zl);
f=[    
    (Vterm*Vinf*sin(Vterm_theta-theta_inf)/X)-Pt; % Sets (Vterm,Vterm_theta)
    (Vterm^2/X-Vterm*Vinf*cos(Vterm_theta-theta_inf)/X)-Qt;  % Sets (Vterm,Vterm_theta)
    Vterm*Ipterm-real(Sload)-Pt; % set Pt, net nodal real power at term bus
    Vterm*Iqterm-imag(Sload)-Qt; % set Qt
    ];
end


