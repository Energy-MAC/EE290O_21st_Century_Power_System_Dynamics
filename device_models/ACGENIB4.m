function ACGENIB_DAE = ACGENIB4(t, x, machine_params, AVR_params, line_params, infbus_params)
    w = x(1);
    d = x(2);
    eq_p = x(3);
    ed_pp = x(4);
    Emf = x(5);
    
    V_R = x(6);
    V_I = x(7);   
 
    X = line_params.Xl + infbus_params.Xth;
    Y = 1/(1j*X);

    Ybus = [Y, -Y; -Y, Y];
    
    V_bus = [infbus_params.V_inf + 1j*0; 
             V_R + 1j*V_I];
    
    I_bus = Ybus*V_bus;   
  
    [ACGEN_ode, I_Machine] = ACGEN4(t, [w, d, eq_p, ed_pp, Emf], [V_R, V_I], machine_params, AVR_params);
    IM = I_Machine./infbus_params.SystemBaseMVA; 
    
    ACGENIB_DAE = [ACGEN_ode;
                   IM(1) - real(I_bus(2));
                   IM(2) - imag(I_bus(2))];

end              