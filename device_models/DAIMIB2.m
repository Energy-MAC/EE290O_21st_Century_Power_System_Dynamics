function DAIMIB_DAE = DAIMIB2(t,x,inverter_params, line_params, infbus_params)

    V_R = x(20);
    V_I = x(21);
    
    X = 0.15;%line_params.Xl + infbus_params.Xth;
    Y = 1/(1j*X);
   
    Ybus = [Y, -Y; -Y, Y];
    
    %1 = infinite bus
    %2 = inverter
    V_bus = [infbus_params.V_inf + 1j*0; 
             V_R + 1j*V_I];
    
    I_bus = Ybus*V_bus;   
    
    [DAIM_ODE, DAIMI_IR] = DAIM_IRdq(t, x(1:19), [V_R,V_I], inverter_params);
    
    DAIMIB_DAE = [DAIM_ODE;
                  DAIMI_IR(1) - real(I_bus(2));
                  DAIMI_IR(2) - imag(I_bus(2))];