clear all; %clc;
%%Load System Models and Parameters
addpath(genpath('device_models'))
addpath('utils')
parameters

% %Machine Model only. Model 2a Classical Model
options_fsolve = optimoptions('fsolve','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);           
x00_m2 = fsolve(@(x)sync_machine_2states(0, x, [1.14, 1.05*cos(0.44), 1.05*sin(0.44)], machine_params), [1.0, 0.59], options_fsolve);           

machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8);
[t_mm2,y_mm2] = ode15s(@(t,x)sync_machine_2states(t, x, [1.14, 1.05*cos(0.44), 1.05*sin(0.44)], machine_params), [0:0.01:10], x00_m2', opts);
 
figure(1);
plot(t_mm2,y_mm2(:,2));
%axis([0 10 0.0 0.6]);
title('(with stepped p ref)');
ylabel('\delta');
xlabel('Time [s]');

options_fsolve = optimoptions('fsolve','display', 'iter');           
x00_ACGEN2 = fsolve(@(x)ACGEN2(0, x, [1.05*cos(0.44), 1.05*sin(0.44)], machine_params, AVR_params), [1.0, 0.59, 1.14], options_fsolve);           

machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8);
[t_ACGEN2,y_ACGEN2] = ode15s(@(t,x)ACGEN2(t, x, [1.05*cos(0.44), 1.05*sin(0.44)], machine_params, AVR_params), [0:0.01:10], x00_ACGEN2', opts);
 
figure(2);
plot(t_ACGEN2,y_ACGEN2(:,2));
%axis([0 10 0.0 0.6]);
title('(with stepped p ref)');
ylabel('\delta');
xlabel('Time [s]');

options_fsolve = optimoptions('fsolve','display', 'iter');            
x00_OMIB2 = fsolve(@(x)ACGENIB2(0, [1.0, x, 1.05*cos(0.44), 1.05*sin(0.44)], machine_params, AVR_params, line_params, infbus_params), [0.59, 1.14], options_fsolve);           

M = eye(5); M(4,4) = 0; M(5,5) = 0;
machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8, 'Mass',M);
[t_OMIB2,y_OMIB2] = ode15s(@(t,x)ACGENIB2(t, x, machine_params, AVR_params, line_params, infbus_params), [0:0.01:10], [1.0, x00_OMIB2, 1.05*cos(0.44), 1.05*sin(0.44)]', opts);
 
figure(3);
plot(t_OMIB2,y_OMIB2(:,2));
%axis([0 10 0.0 0.6]);
title('(with stepped p ref)');
ylabel('\delta');
xlabel('Time [s]');



%%

%% Machine Model only. Model 2a Classical Model
% options_fsolve = optimoptions('fsolve','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);           
% x00_m4 = fsolve(@(x)sync_machine_4states(0, [1.0, 0.10, x], [1.14, 1.05, 0.0], machine_params), [1.0, 0.10, 1.1, 1.1], options_fsolve);           
% 
% machine_params.tvar_fun = @p_ref_step;
% opts = odeset('RelTol',1e-8,'AbsTol',1e-8);
% [t_mm4, y_mm4] = ode15s(@(t,x)sync_machine_4states(t, x, [1.0, 1.05, 0.0], machine_params), [0:0.01:10], x00_m4', opts);
%  
% figure(2);
% plot(t_mm4,y_mm4(:,2));
% title('(with stepped p ref)');
% ylabel('\delta');
% xlabel('Time [s]');

function machine_params = p_ref_step(t,machine_params)
    if t<1
        machine_params.Pd = 0.6;
    else
        machine_params.Pd = 0.7;
    end
end
