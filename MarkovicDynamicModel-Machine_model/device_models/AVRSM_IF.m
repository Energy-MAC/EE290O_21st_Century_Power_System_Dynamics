function [vars] = AVRSM_IF(t, x, machine_params, AVR_params, line_params, infbus_params)

    
 

    %Synch Generator and AVR
    E = x(1);
    d = x(2);
    w = x(3);
    Qg =x(4);
    theta = x(5);
    V_g = x(6);

    
    vars = [generator([E, d, w], [Qg, theta, V_g], machine_params);
            AVR([V_g, E], AVR_params);
            pf_eqs([Qg, theta], V_g, machine_params, line_params, infbus_params)];

        
end



