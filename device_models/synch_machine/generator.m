function [vars] = generator(x, y, params)
    
    w = x(1);
    d = x(2);
    E = x(3);
    
    theta = y(1);     
    V_g = y(2);
    Qg =y(3);
    
    %get parameters
    M = params.M;
    D = params.D;
    Pd = params.Pd;
    Xg = params.Xg;
    %if E<0, E=0; end
    
    %Machine PowerFlow Equations
    vd = V_g*sin(d-theta); vq = V_g*cos(d-theta);
    id = (E - vq)/Xg; iq = vd/Xg;
   
   Qflow_res = (vq*id - vd*iq) - Qg;
   
   %Machine Non-linear ODE's
   dwdt = 1/M *(Pd - (vq*iq + vd*id) - D*w);
   dddt = w;
   
   vars = [dwdt, dddt, Qflow_res]'; 

end
