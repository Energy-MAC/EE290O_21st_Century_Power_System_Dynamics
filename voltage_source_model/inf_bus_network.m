%modified by Rose

function f = inf_bus_network(Ipterm,Iqterm,Vterm, Vterm_theta,Pline,Qline,params)

% Set Parameters
 Ze=params.Xe;
 ZL=params.ZL;
 Vinf=params.Vinf;
 theta_inf = params.theta_inf;

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
