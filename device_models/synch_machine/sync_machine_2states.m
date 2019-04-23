function machine_ODE = sync_machine_2states(t, x, y, machine_params)
   
    w = x(1);
    d = x(2);
    
    Emf = y(1);

    V_td = y(2);
    V_tq = y(3);
       
    %get parameters
    H = machine_params.H;
    D = machine_params.D;
    Pd = machine_params.Pd;
    Xd = machine_params.Xd;
    Xq = machine_params.Xq;
    if Emf<0, Emf=0; end
    
    ed = V_td*sin(d) - V_tq*cos(d);
    eq = V_tq*sin(d) + V_td*cos(d);

    id = (Emf - eq)/Xd; 
    iq = ed/Xq;  
    
    Pe = (eq*iq + ed*id);
    
    %Machine Non-linear ODE's
    dwdt = (1/(2*H))*(Pd - Pe - D*(w-1));
    dddt = 60*2*pi()*(w-1);
   
    machine_ODE = [dwdt, dddt]'; 

end
