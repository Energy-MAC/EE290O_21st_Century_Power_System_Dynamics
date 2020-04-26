function inverter_dxdt=bound_infSimple(t,x,params);

% Internal states of each block
% Note: everything passed into a sub function must be a param or a state!

% Params
Ze=params.Xe;
ZL=params.ZL;
Vinf=params.Vinf;
theta_inf = params.theta_inf;

X=ZL+Ze;
 
Vt=x(1);
Vt_theta=x(2);
Ipterm=x(3);
Iqterm=x(4);
Pline=x(5);
Qline=x(6);

%need to modfiy this for voltage-source converter!

inverter_dxdt=[
% DAEs
    0; % x(1)dot=0 --> constant
    0;
    0;
    0;
    (Ipterm*Vt)-Vt*Vinf*sin(Vt_theta-theta_inf)/X-Pline;
    (Iqterm*Vt)-(Vt^2/X-Vt*Vinf*cos(Vt_theta-theta_inf)/X)-Qline;  
    ];

end