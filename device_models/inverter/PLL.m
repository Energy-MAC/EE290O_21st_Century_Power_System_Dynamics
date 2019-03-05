function f = PLL(vpll_d, vpll_q, vod, voq, delta_theta_pll, epsilon_pll, delta_theta_vsm)

   %get parameters
   
    wlp = params.wlp; % PLL filter in rad/s
    kp_pll = params.kp_pll; % PLL proportional gain
    ki_pll = params.ki_pll; % PLL integraql gain 

f = [
      %d(vpll,d)/dt = 
      wlp*vod*cos(delta_theta_pll-delta_theta_vsm)+...
      wlp*voq*sin(delta_theta_pll-delta_theta_vsm)...
      -wlp*vpll_d;
      
      %d(vpll,q)/dt = 
      -wlp*vod*sin(delta_theta_pll-delta_theta_vsm)+...
      wlp*voq*cos(delta_theta_pll-delta_theta_vsm)...
      -wlp*vpll_q;
      
      %d(epsilon_pll)/dt = 
      atan(vpll_q/vpll_d);
      
       %delta_theta_pll = 
       wb*kp_pll*atan(vpll_q/vpll_d)...
       +wb*ki_pll*epsilon_pll
       
       ];
end

