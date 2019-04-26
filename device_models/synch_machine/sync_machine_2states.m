function [machine_ODE, I_M] = sync_machine_2states(t, x, y, machine_params)
    
    machine_params = machine_params.tvar_fun(t, machine_params);
       
    w = x(1);
    d = x(2);
    
    Emf_q = y(1);

    V_tR = y(2);
    V_tI = y(3);
       
    %get parameters
    H = machine_params.H;
    D = machine_params.D;
    Pd = machine_params.Pd;
    Xd_p = machine_params.Xd_p;
    Xq = machine_params.Xq;
    BaseMVA = machine_params.MVABase;
    if Emf_q<0, Emf_q=0; end
    
    % DQ-DQ Conversion
    V_dq = RI_dq(d)*[V_tR; V_tI]; 
    
    % Disregard assumption in the book about Xd_p = Xq
    i_q = V_dq(1)/Xd_p;                  %15.36
    i_d = (Emf_q - V_dq(2))/Xd_p;        %15.36
    
    Pe = V_dq(2)*i_q + V_dq(1)*i_d;    %15.35
    
    %Machine Non-linear ODE's
    dwdt = (1/(2*H))*(Pd - Pe - D*(w-1)); %15.5
    dddt = 60*2*pi()*(w-1);               %15.5   
   
    machine_ODE = [dwdt, dddt]'; 
    
    I_M = BaseMVA*dq_RI(d)*[i_d; i_q];

end
