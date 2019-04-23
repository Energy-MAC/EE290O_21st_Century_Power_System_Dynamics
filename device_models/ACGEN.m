function generator_ODE = ACGEN(t, x, y, machine_params, AVR_params)

    machine_params = machine_params.tvar_fun(t, machine_params);

    %Synch Generator and AVR
    w = x(1);   
    d = x(2);
    Emf = x(3);
    
    V_td = y(1);
    V_tq = y(2); 
    
    ed = V_td*sin(d) - V_tq*cos(d);
    eq = V_tq*sin(d) + V_td*cos(d);
    id = (Emf - eq)/machine_params.Xd; 
    iq = ed/machine_params.Xd;    

    generator_ODE = [sync_machine_2states(t, [w, d], [Emf, ed, eq, id, iq], machine_params);
                     AVR(t, Emf, [V_td, V_tq], AVR_params)];

end



