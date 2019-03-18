function [vars] = generator(x,y,params)
    
    E = x(1);
    d = x(2);
    w = x(3);
    
    Q_g =y(1);
    theta = y(2); 
    V_r = y(3);
    V_i = y(4);

    %get parameters
    M = params.M;
    D = params.D;
    Pd = params.Pd;
    Xg = params.Xg;

    %Machine PowerFlow Equations
    Pflow_res = Pd - (E*V_i*sin(d-theta))/Xg;
    Qflow_res = Q_g - V_r^2/(Xg) - E*V_r*cos(d-theta)/Xg;
    
    %Machine Non-linear ODE's
    V_g = sqrt(V_r^2+V_i^2);
    dwdt = 1/M *(Pd - E*V_g/Xg*sin(d-theta) - D*w);
    dddt = w;

    vars = [dwdt, dddt, Pflow_res, Qflow_res]; 

end
