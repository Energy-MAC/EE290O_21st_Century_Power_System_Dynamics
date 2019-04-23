function AVR_ODE = AVR(t, x, y, params)
        
    Emf = x(1);
    V_td = y(1);
    V_tq = y(2);
    V_g = sqrt(V_td^2 + V_tq^2);
    
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