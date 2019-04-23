function ACGENIB_DAE = ACGENIB(t, x, machine_params, AVR_params, line_params, infbus_params)
    w = x(1);   
    d = x(2);
    Emf = x(3);
    
    V_td = x(4);
    V_tq = x(5);   
 
    X = line_params.Xl + infbus_params.Xth;
    Y = 1/(1j*X);

    Ybus = [Y, -Y; -Y, Y];
    
    V_bus = [infbus_params.V_inf + 1j*0; 
             V_td + 1j*V_tq];
    
    I_bus = Ybus*V_bus;
    
    % DQ conversions
    id = (Emf - (V_tq*sin(d) + V_td*cos(d)))/machine_params.Xd; 
    iq = (V_td*sin(d) - V_tq*cos(d))/machine_params.Xq;      
         
    ACGENIB_DAE = [ACGEN(t, [w, d, Emf], [V_td, V_tq], machine_params, AVR_params);
                   id*sin(d) + iq*cos(d) - real(I_bus(2));
                   iq*sin(d) - id*cos(d) - imag(I_bus(2))];

end              