function f = current_control_extref(x,y,params)


    iod = x(1);
    ioq = x(2);  
    phi_d = x(3);
    phi_q = x(4);
    
    vod = y(1); 
    voq = y(2); 
    icvd = y(3); 
    icvq = y(4);   
    xi_d = y(5); 
    xi_q = y(6);
    qm = y(7); 
    delta_theta_vsm = y(8); 
    delta_w_vsm = y(9); 
    vgd = y(10);
    vgq = y(11);
    
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
    
     %d(gamma_d)/dt = 
      -kpv*vod-...
      cf*wg*voq-...
      icvd+...
      (kffi-kpv*rv)*iod+...
      kpv*lv*wg*ioq+...
      kiv*xi_d-...
      kpv*kq*qm+... %changed sign of kpv*kq*qm to -
      kpv*lv*ioq*delta_w_vsm-...
      cf*voq*delta_w_vsm+... *changed sign of cf*voq*delta_w_vsm to -
      kpv*kq*q_ref+... *changed sign of kpv*kq*q_ref to +
      kpv*v_ref; 
      
      %d(gamma,q)/dt = 
      cf*wg*vod-...
      kpv*voq-...
      icvq-...
      kpv*lv*wg*iod+...
      (kffi-kpv*rv)*ioq+...
      kiv*xi_q-...
      kpv*lv*iod*delta_w_vsm+...
      cf*vod*delta_w_vsm; 
      
      %d(io,d)/dt= 
      wb*vod/lg-...
      wb*rg*iod/lg+...
      wb*wg*ioq-... 
      wb*vgd/lg; % Paper eqn error: should be (-) term
      
      %d(io,q)/dt = 
      wb*voq/lg-...
      wb*wg*iod-...
      wb*rg*ioq/lg+...
      wb*vgq/lg; 

      %d(phi_d)/dt= 
      wad*vod-wad*phi_d; 
      
      %d(phi_q)/dt =
      wad*voq-wad*phi_q; 


      ];
      
end

