clear all; clc;
%%Load System Models and Parameters
addpath(genpath('device_models'))
addpath('utils')
parameters

%% Set- up initialization - Find Initial Equilibrium Point
options_fsolve = optimoptions('fsolve','Algorithm','Levenberg-Marquardt','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
flow_init = fsolve(@(x)pf_eqs(x, 1.0, gen, line, infbus), [0.5 0.1], options_fsolve); 
%machine_init = fsolve(@(x)generator(x, [gen.Pd, flow_init(1), flow_init(2), 1.0], gen),[1.0, 0.0, 1.0], options_fsolve);    

%[t, y] = ode15s(@(t, x)AVRSM_IF(t, x, gen, AVR, line, infbus), [0:0.001,10],[machine_init, [gen.Pd, flow_init(1), flow_init(2), 1.0]]);

[t, r] = ode15s(@(t, x)generator(t, x, gen), [0:0.001,10],[[1.06, 1.11, 0.00], [gen.Pd, flow_init(1), flow_init(2)]]);
