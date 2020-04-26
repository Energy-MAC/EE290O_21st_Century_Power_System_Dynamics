function [machine_ODE, I_M] = sync_machine_4states(t, x, y, machine_params)
    
    machine_params = machine_params.tvar_fun(t, machine_params);

    w = x(1);
    d = x(2);
    eq_p = x(3);
    ed_pp = x(4);
      
    Vf = y(1);
    V_tR = y(2);
    V_tI = y(3);
       
    %get parameters
    BaseMVA = machine_params.MVABase;
    Xd = machine_params.Xd;
    Xq = machine_params.Xq;
    Xd_p = machine_params.Xd_p;
    Xq_p = machine_params.Xq_p;
    Xq_pp = machine_params.Xq_pp;
    Td0_p = machine_params.Td0_p;
    Tq0_pp = machine_params.Tq0_pp;

    % Mechanical Parameters
    H = machine_params.H;    
    D = machine_params.D;  
    tm = machine_params.Pd;   
    
    % DQ-DQ Conversion %15.4
    V_dq = RI_dq(d)*[V_tR;V_tI];
      
    i_d = (1/Xd_p)*(eq_p - V_dq(2));                            %15.32
    i_q = (1/Xq_pp)*(V_dq(1) - ed_pp);                          %15.32   
         
    te = V_dq(2)*i_q + V_dq(1)*i_d;                             %15.35
    
    %Machine Non-linear ODE's
    dwdt = (1/(2*H))*(tm - te - D*(w-1));                        %15.5
    dddt = 60*2*pi()*(w-1);                                      %15.5
    deq_pdt = (- eq_p - (Xd - Xd_p)*i_d + Vf)*(1/Td0_p);        %15.31
    ded_ppdt = (- ed_pp + (Xq - Xq_pp)*i_q)*(1/Tq0_pp);          %15.31
   
    machine_ODE = [dwdt, dddt, deq_pdt, ded_ppdt]'; 
    
    I_M = BaseMVA*dq_RI(d)*[i_d; i_q];

end
