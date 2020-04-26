function f = vsm_inertia(x, y, params)
%%%%%%%%%%%%%%%%
% Equations (4) and (5) from D'Arco et al reference
%%%%%%%%%%%%%

    delta_w_vsm = x(1);
    iod = y(1);
    vod = y(2); 
    ioq = y(3);
    voq = y(4);
    vpll_d = y(5);
    vpll_q = y(6);
    epsilon_pll = y(7);
    
    %get parameters
    Ta = params.Ta;
    kd = params.kd;
    kp_pll = params.kp_pll;
    ki_pll = params.ki_pll;
    kw = params.kw; 
    p_ref = params.p_ref;
    w_ref = params.w_ref; 
    wg = params.wg; 
    wb = params.wb; % Rated angular frequency
    
    f = [

    %d(delta_w_vsm)/dt = 
      -iod*vod/Ta-...
      ioq*voq/Ta+...
      kd*kp_pll*atan(vpll_q/vpll_d)/Ta+...
      kd*ki_pll*epsilon_pll/Ta-...
      (kd+kw)*delta_w_vsm/Ta+...
      p_ref/Ta+...
      kw*w_ref/Ta-...
      kw*wg/Ta;

    %d(delta_theta_vsm)/dt = 
      wb*delta_w_vsm 

                                        ];

end