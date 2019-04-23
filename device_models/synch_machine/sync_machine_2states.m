function machine_ODE = sync_machine_2states(t, x, y, params)
   
    w = x(1);
    d = x(2);
    
    Emf = y(1);

    ed = y(2);
    eq = y(3);
    
    id = y(4);
    iq = y(5);
    
    %get parameters
    M = params.M;
    D = params.D;
    Pd = params.Pd;
    if Emf<0, Emf=0; end

    %Machine Non-linear ODE's
    dwdt = (1/2*M) *(Pd - (eq*iq + ed*id) - D*w);
    dddt = w;
   
    machine_ODE = [dwdt, dddt]'; 

end
