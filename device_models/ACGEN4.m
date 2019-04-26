function [generator_ODE, IM] = ACGEN4(t, x, y, machine_params, AVR_params)

    %Synch Generator and AVR
    w = x(1);
    d = x(2);
    eq_p = x(3);
    ed_pp = x(4);
    Vf = x(5);
    
    V_R = y(1);
    V_I = y(2); 
    
    [synch_gen_ode, IM] = sync_machine_4states(t, [w, d, eq_p, ed_pp], [Vf, V_R, V_I], machine_params);
    
    generator_ODE = [synch_gen_ode;
                     AVR(t, Vf, [V_R, V_I], AVR_params)];                                
                     
end



