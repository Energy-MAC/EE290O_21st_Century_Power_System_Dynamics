function x = DAIIB_1bus(t,x,inverter_params, line_params, infbus_params)
    %y = [1;0];
    v_g = x(20);
    theta_g = x(21);
    x = [DAIIB_extref(t,x(1:19),[v_g,theta_g],inverter_params);
         pf_eqs_DAIIB_1bus(x,[v_g,theta_g],inverter_params, line_params, infbus_params)];