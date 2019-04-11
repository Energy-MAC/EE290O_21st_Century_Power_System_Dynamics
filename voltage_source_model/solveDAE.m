%This is the Thevenin Voltage Source Equivalent to the Boundary Current
%Model for modeling the inverter for CIGs

clc;
close all;
clear all;

%% Load System Models and Parameters

%right now everything in same folder
parameters; % call parameters.m to populate workspace
            % includes power controller, thevenin voltage source, coupling
            % impedance parameters

%%
options_dae = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
%x00 = fsolve(@(x)bound_infSimple(x,inverter_params),x0,options_dae);

%% Set up DAE initialization and mass matrix
%FYI:
    %ode15s - stiff differential equations and DAEs, variable order method
    %ode23t - moderately stiff differential equations and DAEs, trap rule

tspan = [0 4*logspace(-6,6)];

%tspan: vector of time values where [t0 final] causes the solver to
%integrate from t0 to tfinal
%y0: column vector of initial conditions at initial time t0
[T,Y] = ode15s('power_controller',tspan,y0);