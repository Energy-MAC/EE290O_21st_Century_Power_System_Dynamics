function inverter_ODE = DAIM(t,x,inverter_params)

    inverter_params = inverter_params.tvar_fun(t, inverter_params);
    
    %VSM variables
    delta_w_vsm=x(1);
    delta_theta_vsm=x(2);
    
    %VCO Variables
    vod=x(3);
    voq=x(4);
    icvd=x(5);
    icvq=x(6);
    xi_d=x(7);
    xi_q=x(8);
    
    %ICO Variables
    gamma_d=x(9);
    gamma_q=x(10);
    iod=x(11);
    ioq=x(12);
    phi_d=x(13);
    phi_q=x(14);

    % PLL Variables
    vpll_d=x(15);
    vpll_q=x(16);
    epsilon_pll=x(17);
    delta_theta_pll=x(18);

    % RPD Variable
    qm=x(19);
    
inverter_ODE=[
    vsm_inertia(delta_w_vsm, [iod, vod, ioq, voq, vpll_d, vpll_q, epsilon_pll], inverter_params);
    voltage_control([vod, voq, icvd, icvq, xi_d, xi_q], [iod, ioq,phi_d, phi_q, gamma_d, gamma_q, qm, delta_w_vsm], inverter_params);
    current_control([iod, ioq,  phi_d, phi_q], [vod, voq,  icvd, icvq,  xi_d, xi_q, qm, delta_theta_vsm, delta_w_vsm], inverter_params);
    PLL([vpll_d, vpll_q, epsilon_pll, delta_theta_pll], [vod, voq,  delta_theta_vsm], inverter_params);
    reactive_power_droop(qm, [iod, vod, ioq, voq], inverter_params);
    ];

    