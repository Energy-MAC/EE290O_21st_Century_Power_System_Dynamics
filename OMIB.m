clear all; %clc;
%%Load System Models and Parameters
addpath(genpath('device_models'))
addpath('utils')
parameters

% Set- up DAE Solver 
options_fsolve = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
x00 = fsolve(@(x)ACGEN(0, x, [1.05, 0.0], machine_params, AVR_params),[0.0, 0.15, 1.0], options_fsolve);

%M = eye(19);
machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8);
[t,y] = ode15s(@(t,x)ACGEN(t,x, [1.05, 0.0], machine_params, AVR_params), [0:0.01:10], x00', opts);

figure(1);
plot(t,y(:,2));
legend({'1-bus','\infty-bus'},'Location','east')
axis([0 10 0.0 0.6]);
title('(with stepped p ref)');
ylabel('\delta');
xlabel('Time [s]');

options_fsolve = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
x00_ib = fsolve(@(x)ACGENIB(0, x, machine_params,  AVR_params, line_params, infbus_params), [0.0, 0.15, 1.0, 1.05, 0.0], options_fsolve);

M = eye(5);
M(4,4) = 0.0; M(5,5) = 0.0;
machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Mass',M);
[t_ib,y_ib] = ode15s(@(t,x)ACGENIB(t, x, machine_params,  AVR_params, line_params, infbus_params), [0:0.01:10], x00_ib', opts);

figure(2);
plot(t_ib,(y_ib(:,2) - y_ib(:,5)));
legend({'1-bus','\infty-bus'},'Location','east')
axis([0 10 0.0 0.6]);
title('(with stepped p ref)');
ylabel('\delta');
xlabel('Time [s]');



%"Response to change in loading"
function machine_params = p_ref_step(t,machine_params)
    if t<1
        machine_params.Pd = 0.6;
    else
        machine_params.Pd = 0.9;
    end
end