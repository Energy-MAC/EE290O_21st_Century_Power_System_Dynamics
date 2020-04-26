clear all; clc;
%%Load System Models and Parameters
addpath(genpath('device_models'))
addpath('utils')
parameters

%% Set- up initialization - Find Initial Equilibrium Point
options_fsolve = optimoptions('fsolve','Algorithm','Levenberg-Marquardt','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
flow_init = fsolve(@(x)pf_eqs(x, 1.0, gen, line, infbus), [0.5 0.1], options_fsolve); 
machine_init = fsolve(@(x)generator(x, [flow_init(2), 1.0, flow_init(1)], gen),[1.0, 0.0, 1.0], options_fsolve);    


M = [1, 0, 0, 0, 0;
     0, 1, 0, 0, 0;
     0, 0, 1, 0, 0;
     0, 0, 0, 0, 0;
     0, 0, 0, 0, 0;];
opts = odeset('Mass', M, 'RelTol',1e-8,'AbsTol',1e-8);
[t,y] = ode23t(@(t,x)AVRSM_IFSE(t,x), [0:0.001:20], [machine_init'; flow_init(2); 1.0], opts);
