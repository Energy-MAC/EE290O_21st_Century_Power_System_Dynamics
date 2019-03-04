%%Load System Models and Parameters
addpath('device_models')
parameters

%% Set- up DAE Solver 
options = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);

%% Find Solution
[x,fval] = fsolve(@inverter_infinite_bus,x0);%,options);
