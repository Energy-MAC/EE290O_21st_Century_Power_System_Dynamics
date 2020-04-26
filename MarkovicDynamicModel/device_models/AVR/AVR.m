function AVR_ODE = AVR(t, x, y, params)
        
    Emf = x(1);
    V_R = y(1);
    V_I = y(2);
    V_g = sqrt(V_R^2 + V_I^2);
    
    %get parameters
    V_sp = params.V_sp;
    Kv = params.Kv;
    
    %AVR ODE's
    dEmfdt =  Kv*(V_sp - V_g);
    
    if Emf==0  
        dEmfdt=0; 
    end

    AVR_ODE = dEmfdt;

end