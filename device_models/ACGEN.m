function generator_ODE = ACGEN(t, x, y, machine_params, AVR_params)

    machine_params = machine_params.tvar_fun(t, machine_params);

    %Synch Generator and AVR
    w = x(1);   
    d = x(2);
    Emf = x(3);
    
    V_td = y(1);
    V_tq = y(2); 
    
    generator_ODE = [sync_machine_2states(t, [w, d], [Emf, V_td, V_tq], machine_params);
                     AVR(t, Emf, [V_td, V_tq], AVR_params)];

end



