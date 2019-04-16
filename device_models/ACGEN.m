function [vars] = AVRSM_IF(t, x, machine_params, AVR_params, line_params, infbus_params)

    %Synch Generator and AVR
    E = x(1);
    d = x(2);
    w = x(3);
    theta = infbus_params.Theta_inf;
    V_g = infbus_params.V_inf;
    lp = line_params;
    
    
    
    vars = [generator([w, d], [E, theta, V_g], machine_params);
            AVR(E, V_g, AVR_params)];

        
end



