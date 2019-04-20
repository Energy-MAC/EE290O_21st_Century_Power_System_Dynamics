function DAIMIB_ODE = DAIMIB(t,x,inverter_params, line_params, infbus_params)

    V_g = x(20);
    theta_g = x(21);
        
    Q_gen = x(19);
    
    DAIMIB_ODE = [DAIM(t, x(1:19), [V_g,theta_g], inverter_params);
                  pf_eq_IB(Q_gen, [V_g,theta_g], inverter_params.p_ref, line_params, infbus_params)];