function f = battery(x,y,params)
    
    v_dc = x(1);
    i_dc = x(2);  
    v_in = x(3);
    v_e = x(4);
    d1 = x(5);

    vod=y(1);
    icvd=y(2);
    voq=y(3);
    icvq=y(4);
 %get parameters
 
    Ts = params.fs; 
    l_b = params.l_b;
    c_dc = params.c_dc;
    c_batt = params.c_batt;
    r_batt = params.r_batt;
    v_batt = params.v_batt;
    v_dc_ref = params.v_dc_ref;
    kp_b = params.kp_b;
    ki_b = params.ki_b;

f = [
    %Voltage in the DC Capacitor
    %d(v_dc)/dt =
     i_dc/c_dc-(d1.^2*Ts*v_in)/(2*l_b*c_dc)-(vod*icvd+voq*icvq)/(v_dc*c_dc);
     
     %d(i_dc)/dt = 
     ((2*i_dc)/(d1*Ts))*(1-v_dc/v_in)+(d1*v_dc)/l_b;
     
     %d(v_in)/dt =
     (v_batt-v_in)/(c_batt*r_batt) - i_dc/c_batt;
     
     %d(v_e)/dt =
     v_dc_ref-v_dc;
     
     %Algebraic Eq for s =
     -d1+kp_b*(v_dc_ref-v_dc)+ki_b*v_e;
     ];
end