function ACGENIB_ODE = ACGENIB(t, x, machine_params, AVR_params, line_params, infbus_params)
    w = x(1);   
    d = x(2);
    E = x(3);
    
    V_g = x(4);
    theta_g = x(5);
    
    Q_gen = (V_g^2/(machine_params.Xg) - E*V_g*cos(d-theta_g)/machine_params.Xg);
    
    ACGENIB_ODE = [ACGEN(t, [w, d, E], [V_g, theta_g], machine_params, AVR_params);
                   pf_eq_IB(Q_gen, [V_g, theta_g], machine_params.Pd, line_params, infbus_params)];
end              