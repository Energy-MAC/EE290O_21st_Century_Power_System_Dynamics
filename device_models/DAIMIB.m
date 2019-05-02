function DAIMIB_DAE = DAIMIB(t,x,inverter_params, line_params, infbus_params)

    V_R = x(20);
    V_I = x(21);
    
    X = line_params.Xl;%line_params.Xl + infbus_params.Xth;
    Y = 1/(1j*X);
   
    Ybus = [Y, -Y; -Y, Y];
    
    %1 = infinite bus
    %2 = inverter
    V_bus = [infbus_params.V_inf + 1j*0; 
             V_R + 1j*V_I];
    
    I_bus = Ybus*V_bus;   
    
    [DAIM_ODE, DAIMI_RI] = DAIM_RIdq(t, x(1:19), [V_R,V_I], inverter_params);
    
    DAIMI_sysMVA = DAIMI_RI./infbus_params.SystemBaseMVA;
    
    DAIMIB_DAE = [DAIM_ODE;
                  DAIMI_sysMVA(1) - real(I_bus(2));
                  DAIMI_sysMVA(2) - imag(I_bus(2))];