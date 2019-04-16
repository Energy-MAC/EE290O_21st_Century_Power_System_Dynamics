function [vars] = AVR(x, y, params)
        
    E = x(1);
    V_g = y(1);
    
    %get parameters
    V_sp = params.V_sp;
    Kv = params.Kv;
    
    %AVR ODE's
    dEdt =  Kv*(V_sp - V_g);
    
    if E==0  
        dEdt=0; 
    end

    vars = dEdt;

end