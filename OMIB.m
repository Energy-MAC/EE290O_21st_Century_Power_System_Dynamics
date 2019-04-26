clear all; clc; close all;
%%Load System Models and Parameters
addpath(genpath('device_models'))
addpath('utils')
parameters

%% Power Flow initializer
S=bldybus(S); 
bldpfloweqs(S)
S=pflow(S);
V_R = S.Bus.Voltages(2)*cosd(S.Bus.Angles(2));
V_I = S.Bus.Voltages(2)*sind(S.Bus.Angles(2));
V_bus = [infbus_params.V_inf + 1j*0; 
         V_R + 1j*V_I];
I_RI_BUS = S.Ybus*V_bus;
S_BUS = V_bus.*conj(I_RI_BUS);

% Initialization according to page 225 for 4 state machine model.
% The division (100/615) is the per-unit conversion system <-> machine 
S_M = (100/615)*V_bus(2)*conj(I_RI_BUS(2));  P_M = real(S_M);         %9.11
I_RI_M = conj(S_M)/conj(V_bus(2));                                    %9.11

d_0 =  angle(V_bus(2) + 1j*machine_params.Xq*I_RI_M);                 %9.11

V_dq_M =  RI_dq(d_0)*[real(V_bus(2)); imag(V_bus(2))];               %9.12
I_dq_M =  RI_dq(d_0)*[real(I_RI_M); imag(I_RI_M)];                      %9.12                                                                      
eq_p0  = V_dq_M(2) + machine_params.Xd_p*I_dq_M(1);                   %9.12
ed_pp0 = V_dq_M(1) - machine_params.Xq_pp*I_dq_M(2);                  %9.12
vf0 = eq_p0 + (machine_params.Xd - machine_params.Xd_p)*I_dq_M(1);    %9.12

%% Machine Model only. Model 2a Classical Model
options_fsolve = optimoptions('fsolve','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);           
x00_m2 = fsolve(@(x)sync_machine_2states(0, [1.0, x], [eq_p0, V_R, V_I], machine_params), d_0, options_fsolve);           

machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8);
[t_mm2,y_mm2] = ode15s(@(t,x)sync_machine_2states(t, x, [eq_p0, V_R, V_I], machine_params), [0:0.01:30], [1.0, x00_m2]', opts);
 
figure(1);
plot(t_mm2,y_mm2(:,2)); 
%axis([0 10 0.0 0.6]);
title('(\delta with stepped p_{ref} 0.6 - 0.7 p.u.)');
ylabel('\delta');
xlabel('Time [s]');
hold on;

options_fsolve = optimoptions('fsolve','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);           
x00_m4 = fsolve(@(x)sync_machine_4states(0, [1.0, x], [vf0, V_R, V_I], machine_params),  [d_0, eq_p0, ed_pp0], options_fsolve);           

machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8);
[t_mm4, y_mm4] = ode15s(@(t,x)sync_machine_4states(t, x, [vf0, V_R, V_I], machine_params), [0:0.01:30], [1.0, x00_m4]', opts);
 
plot(t_mm4,y_mm4(:,2));
title('(\delta with stepped p_{ref} 0.6 - 0.7 p.u.)');
ylabel('\delta');
xlabel('Time [s]');
legend('2-State Model 2.a','4-State 2-Axis Model 4.b')
hold off

%% Models with AVR, fixed Terminal Voltage
options_fsolve = optimoptions('fsolve','display', 'iter');           
x00_ACGEN2 = fsolve(@(x)ACGEN2(0, [1.0, x], [V_R, V_I], machine_params, AVR_params), [d_0, eq_p0], options_fsolve);           

machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8);
[t_ACGEN2,y_ACGEN2] = ode15s(@(t,x)ACGEN2(t, x, [V_R, V_I], machine_params, AVR_params), [0:0.01:50], [1.0, x00_ACGEN2]', opts);
 
figure(2);
plot(t_ACGEN2,y_ACGEN2(:,2));
%axis([0 10 0.0 0.6]);
title('(\delta with stepped p_{ref} 0.6 - 0.7 p.u.)');
ylabel('\delta');
xlabel('Time [s]');
hold on;

options_fsolve = optimoptions('fsolve','display', 'iter');           
x00_ACGEN4 = fsolve(@(x)ACGEN4(0, [1.0, x], [V_R, V_I], machine_params, AVR_params), [d_0, eq_p0, ed_pp0, vf0], options_fsolve);           

machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8);
[t_ACGEN4,y_ACGEN4] = ode15s(@(t,x)ACGEN4(t, x, [V_R, V_I], machine_params, AVR_params), [0:0.01:50], [1.0, x00_ACGEN4]', opts);
 
plot(t_ACGEN4,y_ACGEN4(:,2));
title('(\delta with stepped p_{ref} 0.6 - 0.7 p.u.)');
ylabel('\delta');
xlabel('Time [s]');
legend('2-State Model 2.a','4-State 2-Axis Model 4.b')
hold off

%% Models with AVR regulating terminal voltage
options_fsolve = optimoptions('fsolve','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8,'display', 'iter');            
x00_OMIB2 = fsolve(@(x)ACGENIB2(0, [1.0, x, V_R, V_I], machine_params, AVR_params, line_params, infbus_params), [d_0, eq_p0], options_fsolve);           

M = eye(5); M(4,4) = 0; M(5,5) = 0;
machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8, 'Mass',M);
[t_OMIB2,y_OMIB2] = ode15s(@(t,x)ACGENIB2(t, x, machine_params, AVR_params, line_params, infbus_params), [0:0.01:30], [1.0, x00_OMIB2, V_R, V_I]', opts);
 
options_fsolve = optimoptions('fsolve','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8,'display', 'iter');                        
x00_OMIB4 = fsolve(@(x)ACGENIB4(0, [1.0, x, V_R, V_I], machine_params, AVR_params, line_params, infbus_params), [d_0, eq_p0, ed_pp0, vf0], options_fsolve);           

M = eye(7); M(6,6) = 0; M(7,7) = 0;
machine_params.tvar_fun = @p_ref_step;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8, 'Mass',M);
[t_OMIB4,y_OMIB4] = ode15s(@(t,x)ACGENIB4(t, x, machine_params, AVR_params, line_params, infbus_params), [0:0.01:30], [1.0, x00_OMIB4, V_R, V_I]', opts);

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