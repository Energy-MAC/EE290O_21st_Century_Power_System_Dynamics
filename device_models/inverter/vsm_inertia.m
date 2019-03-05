function f = vsm_inertia(iod, vod, ioq, voq, vpll_d, vpll_q, epsilon_pll, delta_w_vsm, params)
%%%%%%%%%%%%%%%%
% Equations (4) and (5) from D'Arco et al reference
%%%%%%%%%%%%%

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