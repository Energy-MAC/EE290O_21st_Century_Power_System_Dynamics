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
[t_mm2,y_mm2] = ode15s(@(t,x)sync_machine_2states(t, x, [1.14, 1.05*cos(0.44), 1.05*sin(0.44)], machine_params), [0:0.01:30], x00_m2', opts);
 
figure(1);
plot(t_mm2,y_mm2(:,2));
%axis([0 10 0.0 0.6]);
title('(\delta with stepped p_{ref} 0.6 - 0.7 p.u.)');
ylabel('\delta');
xlabel('Time [s]');
hold on;

% Machine Model only. Model 4b 2-Axis 
options_fsolve = optimoptions('fsolve','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);           
x00_m4 = fsolve(@(x)sync_machine_4states(0, [1.0, x], [1.14, 1.05*cos(0.44), 1.05*sin(0.44)], machine_params), [0.10, 1.1, 1.1], options_fsolve);           

machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8);
[t_mm4, y_mm4] = ode15s(@(t,x)sync_machine_4states(t, x, [1.14, 1.05*cos(0.44), 1.05*sin(0.44)], machine_params), [0:0.01:30], [1.0, x00_m4]', opts);
 
plot(t_mm4,y_mm4(:,2));
title('(\delta with stepped p_{ref} 0.6 - 0.7 p.u.)');
ylabel('\delta');
xlabel('Time [s]');
legend('2-State Model 2.a','4-State 2-Axis Model 4.b')
hold off

%% Models with AVR, fixed Terminal Voltage
options_fsolve = optimoptions('fsolve','display', 'iter');           
x00_ACGEN2 = fsolve(@(x)ACGEN2(0, x, [1.05*cos(0.44), 1.05*sin(0.44)], machine_params, AVR_params), [1.0, 0.59, 1.14], options_fsolve);           

machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8);
[t_ACGEN2,y_ACGEN2] = ode15s(@(t,x)ACGEN2(t, x, [1.05*cos(0.44), 1.05*sin(0.44)], machine_params, AVR_params), [0:0.01:30], x00_ACGEN2', opts);
 
figure(2);
plot(t_ACGEN2,y_ACGEN2(:,2));
%axis([0 10 0.0 0.6]);
title('(\delta with stepped p_{ref} 0.6 - 0.7 p.u.)');
ylabel('\delta');
xlabel('Time [s]');
hold on;

options_fsolve = optimoptions('fsolve','display', 'iter');           
x00_ACGEN4 = fsolve(@(x)ACGEN4(0, [1.0, x], [1.05*cos(0.44), 1.05*sin(0.44)], machine_params, AVR_params), [0.59, 1.14, 1.0, 1.0], options_fsolve);           

machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8);
[t_ACGEN4,y_ACGEN4] = ode15s(@(t,x)ACGEN4(t, x, [1.05*cos(0.44), 1.05*sin(0.44)], machine_params, AVR_params), [0:0.01:30], [1.0, x00_ACGEN4]', opts);
 
plot(t_ACGEN4,y_ACGEN4(:,2));
title('(\delta with stepped p_{ref} 0.6 - 0.7 p.u.)');
ylabel('\delta');
xlabel('Time [s]');
legend('2-State Model 2.a','4-State 2-Axis Model 4.b')
hold off

%% Models with AVR regulating terminal voltage
options_fsolve = optimoptions('fsolve','display', 'iter');            
x00_OMIB2 = fsolve(@(x)ACGENIB2(0, [1.0, x, 1.05*cos(0.44), 1.05*sin(0.44)], machine_params, AVR_params, line_params, infbus_params), [0.59, 1.14], options_fsolve);           

M = eye(5); M(4,4) = 0; M(5,5) = 0;
machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8, 'Mass',M);
[t_OMIB2,y_OMIB2] = ode15s(@(t,x)ACGENIB2(t, x, machine_params, AVR_params, line_params, infbus_params), [0:0.01:30], [1.0, x00_OMIB2, 1.05*cos(0.44), 1.05*sin(0.44)]', opts);
 
options_fsolve = optimoptions('fsolve','display', 'iter');            
x00_OMIB4 = fsolve(@(x)ACGENIB4(0, [1.0, x, 1.05*cos(0.44), 1.05*sin(0.44)], machine_params, AVR_params, line_params, infbus_params), [0.59, 1.14, 1.0, 1.0], options_fsolve);           

M = eye(7); M(6,6) = 0; M(7,7) = 0;
machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8, 'Mass',M);
[t_OMIB4,y_OMIB4] = ode15s(@(t,x)ACGENIB4(t, x, machine_params, AVR_params, line_params, infbus_params), [0:0.01:30], [1.0, x00_OMIB4, 1.05*cos(0.44), 1.05*sin(0.44)]', opts);

figure(3);
plot(t_OMIB2,y_OMIB2(:,2));
%axis([0 10 0.0 0.6]);
title('(\delta with stepped p_{ref} 0.6 - 0.7 p.u.)');
ylabel('\delta');
xlabel('Time [s]');
hold on

plot(t_OMIB4,y_OMIB4(:,2));
%axis([0 10 0.0 0.6]);
title('(\delta with stepped p_{ref} 0.6 - 0.7 p.u.)');
ylabel('\delta');
xlabel('Time [s]');
legend('2-State Model 2.a','4-State 2-Axis Model 4.b')
hold off

figure(4);
plot(t_OMIB2, sqrt(y_OMIB2(:,4).^2 + y_OMIB2(:,5).^2));
title('(V_{terminals} with stepped p_{ref} 0.6 - 0.7 p.u.)');
ylabel('V_{terminals}');
xlabel('Time [s]');
hold on

plot(t_OMIB4, sqrt(y_OMIB4(:,6).^2 + y_OMIB4(:,7).^2));
%axis([0 10 0.0 0.6]);
title('(V_{terminals} with stepped p_{ref} 0.6 - 0.7 p.u.)');
ylabel('V_{terminals}');
xlabel('Time [s]');
legend('2-State Model 2.a','4-State 2-Axis Model 4.b')
hold off

figure(5);
plot(t_OMIB2, y_OMIB2(:,3));
title('(e_{q}'' with stepped p_{ref} 0.6 - 0.7 p.u.)');
ylabel('e_{q}''');
xlabel('Time [s]');
hold on

plot(t_OMIB4, y_OMIB4(:,3));
%axis([0 10 0.0 0.6]);
title('(e_{q}'' with stepped p_{ref} 0.6 - 0.7 p.u.)');
ylabel('e_{q}''');
xlabel('Time [s]');
legend('2-State Model 2.a','4-State 2-Axis Model 4.b')
hold off

function machine_params = p_ref_step(t,machine_params)
    if t<1
        machine_params.Pd = 0.4;
    else
        machine_params.Pd = 0.7;
    end
end

function machine_params = p_ref_ramp(t,machine_params)
    if t<1
        machine_params.Pd = 0.4;
    elseif (t<2)
        machine_params.Pd = 1+(0.4*(t-1)); % At t=2, 1-0.005 = .995
    else
        machine_params.Pd = 0.7;
    end
end