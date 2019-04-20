function f = dc_side(iod, vod, ioq, voq, icvd, icvq, phi_d, phi_q, xi_d, xi_q, qm, delta_theta_vsm, delta_w_vsm, params)

 %get parameters
 
    kpv = params.kpv; % Voltage controller gain
    kiv = params.kiv; % Voltage controller gain
    wb = params.wb; 
    wg = params.wg; 
    cf = params.cf; % Filter capacitance in p.u.
    kffi = params.kffi;
    lg = params.lg; % Grid inductance in p.u.
    rg = params.rg; % Grid resistance in p.u.    
    wad = params.wad; % Active damping filte
    rv = params.rv;
    lv = params.lv;
    kq = params.kq;
    q_ref = params.q_ref;
    v_ref = params.v_ref;
    vg = params.vg;
f = [
    
     %d(V_dc)/dt = 
     (1-2*S)*(ib/C_dc) - (vd*id+vq*iq)/(c_dc*v_dc)

      ];
      
end