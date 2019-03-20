function [vars] = AVR(x, params)
        
    V_g = x(1);
    E = x(2);
    
    %get parameters
    V_sp = params.V_sp;
    Kv = params.Kv;
    
    %AVR ODE's
    dEdt =  Kv*(V_sp - V_g);
    
    if E==0  
        dEdt=0 
    end

    vars = dEdt;

end