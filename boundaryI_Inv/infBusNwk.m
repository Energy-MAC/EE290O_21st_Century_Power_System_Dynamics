function f = infBusNwk(Ipterm,Iqterm,Vterm, Vterm_theta,Pline,Qline,params)
% Params
 Ze=params.Xe
 ZL=params.ZL
 Vinf=params.Vinf
 theta_inf = params.theta_inf;

% NOTE: PHASOR REP DOESNT WORK
% f=[
%     %0=
%     ((Ipterm+j*Iqterm)*Ze*ZL+Vinf*ZL)/(ZL+j*Ze)-Vg
%     %0=
%     (Vg-Vinf)/Ze-I1;
%     %0=
%     Vg/ZL-I2;
% ];

X=ZL+Ze;
f=[    
    (Ipterm*Vterm)-Vterm*Vinf*sin(Vterm_theta-theta_inf)/X-Pline;
    (Iqterm*Vterm)-Vterm^2/X-Vterm*Vinf*cos(Vterm_theta-theta_inf)/X-Qline;  
];
end

% CURI CODE FOR REFERENCE
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
