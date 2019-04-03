function inverter_dxdt = inverter_infinite_bus(t,x,inverter_params)

    %VSM variables
    delta_theta_vsm=x(14);
    delta_w_vsm=x(18);

    %VCO Variables
    vod=x(1);
    voq=x(2);

    %ICO Variables
    icvd=x(3);
    icvq=x(4);
    gamma_d=x(5);
    gamma_q=x(6);
    iod=x(7);
    ioq=x(8);

    phi_d=x(9);
    phi_q=x(10);

    % PLL Variables
    vpll_d=x(11);
    vpll_q=x(12);
    epsilon_pll=x(13);

    xi_d=x(15);
    xi_q=x(16);
    qm=x(17);

    delta_theta_pll=x(19);
    
inverter_dxdt=[
           vsm_inertia(iod, vod, ioq, voq, vpll_d, vpll_q, epsilon_pll, delta_w_vsm, inverter_params);
           voltage_control(iod, vod, ioq, voq, icvd, icvq, phi_d, phi_q, xi_d, xi_q, gamma_d, gamma_q, qm, delta_w_vsm, inverter_params)
           current_control(iod, vod, ioq, voq, icvd, icvq, phi_d, phi_q, xi_d, xi_q, qm, delta_theta_vsm, delta_w_vsm, inverter_params)
           PLL(vpll_d, vpll_q, vod, voq, delta_theta_pll, epsilon_pll, delta_theta_vsm, inverter_params)  
           reactive_power_droop(iod, vod, ioq, voq, qm, inverter_params)    
      
       ];