function f = PLL_extref(x,y, params)


    vpll_d = x(1); 
    vpll_q = x(2);
    epsilon_pll = x(3);
    delta_theta_pll = x(4);
    
    vod = y(1);
    voq = y(2);
    delta_theta_vsm = y(3);
    theta_g = y(4);    
    
   %get parameters
   
    wlp = params.wlp; % PLL filter in rad/s
    kp_pll = params.kp_pll; % PLL proportional gain
    ki_pll = params.ki_pll; % PLL integraql gain 
    wb = params.wb;
    wg = params.wg;

f = [
      %d(vpll,d)/dt = 
      wlp*vod*cos(delta_theta_pll-delta_theta_vsm+theta_g)+...
      wlp*voq*sin(delta_theta_pll-delta_theta_vsm+theta_g)-...
      wlp*vpll_d;
      
      %d(vpll,q)/dt = 
      -wlp*vod*sin(delta_theta_pll-delta_theta_vsm+theta_g)+...
      wlp*voq*cos(delta_theta_pll-delta_theta_vsm+theta_g)-...
      wlp*vpll_q;
      
      %d(epsilon_pll)/dt = 
      atan(vpll_q/vpll_d);
      
       %delta_theta_pll = 
       wb*kp_pll*atan(vpll_q/vpll_d)+...
       wb*ki_pll*epsilon_pll;
       
       ];
end

