function [vars] = pf_eq_IB(x, y, Pd, line_params, infbus_params)
    
    Q_g = x(1);
    theta = y(2); 
    V_g = y(1);
    
    V_inf = infbus_params.V_inf;
    theta_inf = infbus_params.Theta_inf;
    
    Xl = line_params.Xl;
    Xth = infbus_params.Xth;
    X= Xl;%+Xth;
       
    P_res =  Pd - V_inf*V_g*sin(theta-theta_inf)/X;
    Q_res =  Q_g - (V_g^2/(X) - V_inf*V_g*cos(theta-theta_inf)/X);
    
    vars = [P_res, Q_res]';
end