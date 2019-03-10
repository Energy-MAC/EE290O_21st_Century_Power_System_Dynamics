clear all; %clc;
%%Load System Models and Parameters
addpath(genpath('device_models'))
addpath('utils')
parameters

%% Set- up DAE Solver 
options_dae = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
x = fsolve(@(x)inverter_infinite_bus(x,inverter_params),x0_inverter,options_dae);
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
  x