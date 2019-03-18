clear all; clc;
%%Load System Models and Parameters
addpath(genpath('device_models'))
addpath('utils')
parameters

%% Set- up initialization - Find Initial Equilibrium Point
options_fsolve = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
flow_init = fsolve(@(x)pf_eqs(x, gen, line, infbus), [0 0 1], options_fsolve); 
machine_init = fsolve(@(x)generator(x,[flow_init(1), flow_init(2), flow_init(3)*cos(flow_init(2)), flow_init(3)*sin(flow_init(2))], gen),[1.0, 0.0, 1.0], options_fsolve);    
%AVR_init simple feedback model isn't a problem

%% Solve DAE.

[t, y] = ode23t(@AVRSM_IF,[0:0.001,t3],[flow_init, machine_init]);


