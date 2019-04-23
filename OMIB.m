clear all; %clc;
%%Load System Models and Parameters
addpath(genpath('device_models'))
addpath('utils')
parameters

% Get Ini_cond
Ini_V_bus = [1.0 + 1j*0;
             1.05*cos(0.44) + 1j*1.05*sin(0.44)];

X = line_params.Xl + infbus_params.Xth;
Y = 1/(1j*X);

Ybus = [Y, -Y; -Y, Y];

Ini_i = Ybus*Ini_V_bus;

grid_vals =   [real(Ini_V_bus(2))
               imag(Ini_V_bus(2))];

% Set- up DAE Solver 
options_fsolve = optimoptions('fsolve','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
x00 = fsolve(@(x)ACGEN(0, x, grid_vals(1:2), machine_params, AVR_params), [0.0, 0.15, 1.1], options_fsolve);


machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8);
[t,y] = ode15s(@(t,x)ACGEN(t,x, grid_vals', machine_params, AVR_params), [0:0.01:10], x00', opts);
 
figure(1);
plot(t,y(:,2));
legend({'1-bus','\infty-bus'},'Location','east')
%axis([0 10 0.0 0.6]);
title('(with stepped p ref)');
ylabel('\delta');
xlabel('Time [s]');

ini_cond_pf = [0.0 
               0.15 
               1.1 
               real(Ini_V_bus(2))
               imag(Ini_V_bus(2))];

options_fsolve = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
x00_ib = fsolve(@(x)ACGENIB(0, x, machine_params,  AVR_params, line_params, infbus_params), ini_cond_pf', options_fsolve);

M = eye(5);
M(4,4) = 0.0; 
M(5,5) = 0.0;
machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Mass',M);
[t_ib,y_ib] = ode15s(@(t,x)ACGENIB(t, x, machine_params,  AVR_params, line_params, infbus_params), [0:0.01:10], x00_ib', opts);

figure(2);
plot(t_ib,(y_ib(:,2)));
legend({'1-bus','\infty-bus'},'Location','east')
axis([0 10 0.0 0.6]);
title('(with stepped p ref)');
ylabel('\delta');
xlabel('Time [s]');           
           
function machine_params = p_ref_step(t,machine_params)
    if t<1
        machine_params.Pd = 0.6;
    else
        machine_params.Pd = 0.9;
    end
end
