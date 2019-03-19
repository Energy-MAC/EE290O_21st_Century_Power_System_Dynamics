function [vars] = AVRSM_IF(t, x, machine_params, AVR_params, line_params, infbus_params)
    
    %Synch Generator and AVR
    E = x(1);
    d = x(2);
    w = x(3);
    P_g = x(4);
    Q_g =x(5);
    theta = x(6);
    V_g = x(7);

    
    vars = [generator([E, d, w], [P_g, Q_g, theta, V_g], machine_params);
            AVR([E, V_g], AVR_params);
            pf_eqs([Q_g, theta], V_g, machine_params, line_params, infbus_params)];

        
end



