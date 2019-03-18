function [vars] = AVRSM_IF(x, machine_params, AVR_params, line_params, infbus_params)
    
    %Synch Generator and AVR
    E = x(1);
    d = x(2);
    theta = x(3); 
    w = x(4);
    P_g = x(5);
    Q_g =x(6);
    V_r = x(7);
    V_i = x(8);
    
    

    vars = [generator(E, d, theta, w, P_g, Q_g, V_r, V_i, machine_params)
            AVR(V_r, V_i, E, AVR_params)
            pf_eqs(P_g, Q_g, theta, sqrt(V_r^2+V_i^2), line_params, infbus_params)];

        
end



