clear all; %clc;
%%Load System Models and Parameters
addpath(genpath('device_models'))
addpath('utils')
parameters

%% Set- up DAE Solver 
options_dae = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
x00 = fsolve(@(x)inverter_infinite_bus(0,x,inverter_params),x0,options_dae);

M = eye(19);
opts = odeset('Mass',M, 'RelTol',1e-8,'AbsTol',1e-8);%%,'InitialSlope',zeros(19,1));
[t1,y1] = ode23t(@(t,x)inverter_infinite_bus(t,x,inverter_params), [0:0.01:1], x00', opts);
inverter_params.p_ref = 0.7
M(18,18) = 0;
[t2,y2] = ode23s(@(t,x)inverter_infinite_bus(t,x,inverter_params), [1.001:0.001:2], y1(end,:)', opts);
y = [y1; y2];