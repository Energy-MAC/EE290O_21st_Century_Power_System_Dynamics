function [vars] = generator(t, x, params)
    
    E = x(1);
    d = x(2);
    w = x(3);

    Pg = x(4);
    Qg =x(5);
    theta = x(6); 
    V_g = x(7);
    
    %Pg = y(1);
    %Qg =y(2);
    %theta = y(3); 
    %V_g = y(4);
   

    %get parameters
    M = params.M;
    D = params.D;
    Pd = params.Pd;
    Xg = params.Xg;

    %Machine PowerFlow Equations
    vd = V_g*sin(d-theta); vq = V_g*cos(d-theta);
    id = (E - vq)/Xg; iq = vd/Xg;
    
    Pflow_res = vq*iq + vd*id - Pg;
    Qflow_res = vq*id - vd*iq - Qg;

    if E<0, E=0; end
    %Machine Voltage Circuit
    vd_res = vd - Xg*iq;
    vq_res = vq + Xg*id - E;
    
    %Machine Non-linear ODE's
    dwdt = 1/M *(Pd - Pg - D*w);
    dddt = w;

    vars = [dwdt, dddt, vd_res, vq_res, Pflow_res, Qflow_res]'; 

end
