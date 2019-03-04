x0=[1, 0, 0.5, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0.2, 1, 1, 0.025,0, 0.1];
options = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
[x,fval] = fsolve(@inverter_infinite_bus,x0);%,options);
