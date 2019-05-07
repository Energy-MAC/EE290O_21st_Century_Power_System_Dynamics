clear all; %clc;
%%Load System Models and Parameters
addpath(genpath('device_models'))
addpath('utils')
parameters
inverter_params.kd = 1;
%% Set- up DAE Solver 
options_dae = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
x00 = fsolve(@(x)DAIIB_battery(0,x,inverter_params,battery_params),x0,options_dae);
M = eye(24);
M(24,24)=0;
opts = odeset('RelTol',1e-8,'AbsTol',1e-8,'Mass',M);

% Time varying parameters need to be executed inside of ode solver so a
% function can be embedded in the parameter structure passed to the solver.
% Specific time varying statements can be defined at the bottom of the
% script.
inverter_params.tvar_fun = @p_ref_step;
[t4_1,y4_1] = ode23t(@(t,x)DAIIB_battery(t,x,inverter_params,battery_params), [0:0.01:5], x00', opts);

figure(1)
plot(t4_1, 700*y4_1(:,20))
ylabel('V_{dc} [Volts]')
xlabel('Time [s]')
title('DC Bus Voltage for P Step)');
figure(2)
plot(t4_1, y4_1(:,21))
ylabel('i_{dc} [p.u.]')
xlabel('Time [s]')
figure(3)
plot(t4_1, y4_1(:,22))
ylabel('v_{in} [p.u.]')
title('Input Voltage to Buck/Boost Converter');
xlabel('Time [s]')
figure(4)
plot(t4_1, y4_1(:,23))
ylabel('v_{dc} error')
title('DC Voltage Error');
xlabel('Time [s]')
figure(5)
plot(t4_1, y4_1(:,24))
title('d1 (Related to duty cycle)');
ylabel('d1')
xlabel('Time [s]')

figure(6);
plot(t4_1,y4_1(:,3).*y4_1(:,11)+y4_1(:,4).*y4_1(:,12));
axis([0 4 0.4 0.8]);
title('Power [pu] (with stepped p ref)');
ylabel('p [pu]');
xlabel('Time [s]');

function inverter_params = p_ref_step(t,inverter_params)
    if t<1
        inverter_params.p_ref = 0.5;
    else
        inverter_params.p_ref = 0.7;
    end
end
