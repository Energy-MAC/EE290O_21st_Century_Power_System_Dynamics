function [vars] = AVR(E, V_r, V_i, params)
     
    %get parameters
    V_sp = params.V_sp;
    Kv = params.Kv;
    
    %AVR ODE's
    dEdt =  Kv * (V_sp - sqrt(V_r^2+V_i^2));
    
    if E==0,  dEdt=0; end

    vars = dEdt;

end