clear all; %clc;
%%Load System Models and Parameters
addpath(genpath('device_models'))
addpath('utils')
parameters

%% Set- up DAE Solver 
options_dae = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
x00 = fsolve(@(x)inverter_infinite_bus(0,x,inverter_params),x0,options_dae);

%M = eye(19);
opts = odeset('RelTol',1e-8,'AbsTol',1e-8);%'Mass',M);
[t,y] = ode23t(@(t,x)inverter_infinite_bus(t,x,inverter_params), [0:0.01:4], x00', opts);
