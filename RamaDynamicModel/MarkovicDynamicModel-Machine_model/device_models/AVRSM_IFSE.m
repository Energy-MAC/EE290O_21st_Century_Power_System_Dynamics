function [vars] = AVRSM_IFSE(t, x)

    Xl = 0.5;
   if t >= 1  %contingency
      Xl = Xl+0.10;
   end

    %Synch Generator and AVR
    E = x(3);
    d = x(2);
    w = x(1);
    theta = x(4);
    V_g = x(5);
    
     %get parameters
    M = 0.1;
    D = 0.1;
    Pd = 0.9;
    Xg = 0.25;
        
    V_inf = 1.0;
    theta_inf = 0.0;

   
    Xth = 0.25;
    X= Xl+Xth;
    

    %Machine PowerFlow Equations
    vd = V_g*sin(d-theta); vq = V_g*cos(d-theta);
    id = (E - vq)/Xg; iq = vd/Xg;
    
    %Vgi= E*(Xl+Xth)/X*sin(d);
    %Vgr= V_inf*(1 - (Xl+Xth)/X) + E*(Xl+Xth)/X*cos(d);
    %V_g =sqrt(Vgr^2+Vgi^2);
   

    P_res =  Pd - V_inf*V_g*sin(theta-theta_inf)/X;
    Q_res =  (vq*id - vd*iq) + (V_g^2/(X) - V_inf*V_g*cos(theta-theta_inf)/X);
        
    
    %Machine Non-linear ODE's
    dwdt = 1/M *(Pd - E*V_g/Xg*sin(d-theta) - D*w);
    dddt = w;
    V_sp = 1.0;
    Kv = 10;

    %AVR ODE's
    dEdt =  Kv*(V_sp - V_g);

    if E==0,  dEdt=0; end

   vars = [dwdt dddt dEdt P_res Q_res].';
end



