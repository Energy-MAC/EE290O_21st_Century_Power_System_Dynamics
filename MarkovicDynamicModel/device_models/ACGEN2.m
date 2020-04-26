function [generator_ODE, IM] = ACGEN2(t, x, y, machine_params, AVR_params)

    %Synch Generator and AVR
    w = x(1);   
    d = x(2);
    Emf = x(3);
    
    V_R = y(1);
    V_I = y(2); 
    
    [synch_gen_ode, IM] = sync_machine_2states(t, [w, d], [Emf, V_R, V_I], machine_params);
    
    generator_ODE = [synch_gen_ode;
                     AVR(t, Emf, [V_R, V_I], AVR_params)];                                
                     
end



