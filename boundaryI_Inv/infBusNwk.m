% Reference: Callaway ERG294 Notes, Lecv 15, virtual pg 210, see Example
% 10.3 too

% Network desc:
% Network has two buses, Vt and Vinf, separated by line Zl
% Vt has generator (inv) and load, ZL

function f = infBusNwk(Ipterm,Iqterm,Vterm, Vterm_theta,Pt,Qt,params)
% Params
 Zl=params.Zl; % line reactance
 ZL=params.ZL; % load, complex
 Vinf=params.Vinf;
 theta_inf = params.theta_inf;

% NOTE: DO NOT USE PHASOR REP FOR PF EQUATIONS,doesnt work

% Transmission line power flow equations between Vt and Vinf
% algebraic, nonlinear
X=Zl;
f=[    
    (Vterm*Vinf*sin(Vterm_theta-theta_inf)/X)-Pt; % Sets (Vterm,Vterm_theta)
    (Vterm^2/X-Vterm*Vinf*cos(Vterm_theta-theta_inf)/X)-Qt;  % Sets (Vterm,Vterm_theta)
    Vterm*Ipterm-Vterm^2/real(ZL)-Pt; % set Pt, net nodal real power at term bus
    Vterm*Iqterm-Vterm^2/imag(ZL)-Qt; % set Qt
    ];
end

% MARKOVIC CODE FOR REFERENCE
% MarkovicDynamicModel/device_models/network/pf_eq_IB.m
%     Q_g = x(1);
%     theta = x(2); 
%     Vg = y(1);    
%     Pd = machine_params.Pd;
%     
%     X= ZL+Ze;
%     P_res =  Pd - V_inf*Vg*sin(theta-theta_inf)/X;
%     Q_res =  Q_g - (Vg^2/(X) - V_inf*Vg*cos(theta-theta_inf)/X);
%     
%     vars = [P_res, Q_res]';


