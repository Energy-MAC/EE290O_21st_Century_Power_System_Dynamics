function generator_ODE = ACGEN(t, x, y, machine_params, AVR_params)

    machine_params = machine_params.tvar_fun(t, machine_params);

    %Synch Generator and AVR
    w = x(1);   
    d = x(2);
    E = x(3);
    
    V_g = y(1);
    theta = y(2);

    generator_ODE = [sync_machine_2states(t, [w, d], [E, theta, V_g], machine_params);
                     AVR(t, E, V_g, AVR_params)];

end



