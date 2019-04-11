clc; close all; clear all;
%%Load System Models and Parameters
% addpath(genpath('device_models'))
% addpath('utils')

parameters % call the parameters.m to set populate workspace
% after calling, workspace will have "inverter_params" and x0 vars


%%
options_dae = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
x00 = fsolve(@(x)bound_infSimple(x,inverter_params),x0,options_dae);

%% Setup DAE init and mass matrix
% have not run this yet, still fixing up
y0 = [1; 0; 0];
tspan = [0 4*logspace(-6,6)];
M=eye(14); % mass matrix to define which eqs are diff vs. alg eqs
M(7,7)=0; % alg eq, QVdroop
M(10,10)=0; % alg eq, current control
M(11,11)=0; % alg eq, current control
M(12,12)=0; % alg eq, inf bus network
M(13,13)=0; % alg eq, inf bus network
M(14,14)=0; % alg eq, inf bus network
%%
% options = odeset('Mass',M,'RelTol',1e-4,'AbsTol',[1e-6 1e-10 1e-6]);
% [t,y] = ode15s(@bounaryinv_infBus,tspan,y0,options);

%[t,x] = ode15s(@(t,x)ode_full_system_modular(t,x,param), tspan, x0, options);

% use fsolve to solve PF and initialize
% use ODE23t or 15s to run dyn sim