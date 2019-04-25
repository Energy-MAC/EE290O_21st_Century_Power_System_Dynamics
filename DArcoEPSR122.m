clear all; %clc;
%%Load System Models and Parameters
addpath(genpath('device_models'))
addpath('utils')
parameters

%% Set- up DAE Solver 
options_dae = optimoptions('fsolve','Algorithm','trust-region-dogleg','StepTolerance', 1e-8,'FunctionTolerance', 1e-8,'MaxFunctionEvaluations',500000, 'MaxIterations',100000,'StepTolerance',1e-8,'OptimalityTolerance', 1e-8);
x00_IB = fsolve(@(x)DAIMIB2(0,x,inverter_params,line_params, infbus_params),[x0,1.02,0],options_dae);
x00 = fsolve(@(x)DAIM(0,x,inverter_params),x0,options_dae);

%x00(20) = 1;
%x00(21) = 0;
M = eye(21);
M(20,20)=0;
M(21,21)=0;
opts_IB = odeset('RelTol',1e-8,'AbsTol',1e-8,'Mass',M);
opts = odeset('RelTol',1e-8,'AbsTol',1e-8);%'Mass',M);

% Time varying parameters need to be executed inside of ode solver so a
% function can be embedded in the parameter structure passed to the solver.
% Specific time varying statements can be defined at the bottom of the
% script.
inverter_params.tvar_fun = @p_ref_step;
[t4_1_ext,y4_1_ext] = ode23t(@(t,x)DAIMIB2(t,x,inverter_params, line_params, infbus_params), [0:0.01:10], x00_IB', opts_IB);
[t4_1,y4_1] = ode23t(@(t,x)DAIM(t,x,inverter_params), [0:0.01:10], x00', opts);

inverter_params.tvar_fun = @wg_ramp;
[t4_2_ext,y4_2_ext] = ode23t(@(t,x)DAIMIB2(t,x,inverter_params, line_params, infbus_params), [0:0.01:10], x00_IB', opts_IB);
[t4_2,y4_2] = ode23t(@(t,x)DAIM(t,x,inverter_params), [0:0.01:10], x00', opts);

%Figure 8: Plot power during step response. p = vod*iod+voq*ioq
figure(8);
plot(t4_1_ext,y4_1_ext(:,3).*y4_1_ext(:,11)+y4_1_ext(:,4).*y4_1_ext(:,12),t4_1_ext,y4_1(:,3).*y4_1(:,11)+y4_1(:,4).*y4_1(:,12));
axis([0 10 0.4 0.8]);
legend({'Y-bus','\infty-bus'},'Location','east')
title('Power [pu] (with stepped p ref)');
ylabel('p [pu]');
xlabel('Time [s]');

%Figure 9: Plot w_vsm during step response.
figure(9);
plot(t4_1_ext,1+y4_1_ext(:,1),t4_1,1+y4_1(:,1));
axis([0 10 .999 1.001]);
legend({'Y-bus','\infty-bus'},'Location','east')
title('VSM speed (with stepped p ref)');
ylabel('\omega_{VSM} [rad]')
xlabel('Time [s]');

%Figure 10: Plot d_w_vsm and d_theta_pll during step response.
figure(10);
subplot(2,1,1);
plot(t4_1_ext,y4_1_ext(:,2),t4_1,y4_1(:,2));
axis([0 10 .1 0.6]);
legend({'Y-bus','\infty-bus'},'Location','east')
title('Phase angle orientation of VSM and PLL (with stepped p ref)');
ylabel('\delta\theta_{VSM} [rad]');
subplot(2,1,2);
plot(t4_1_ext,y4_1_ext(:,18),t4_1,y4_1(:,18));
axis([0 10 .05 0.2]);
legend({'Y-bus','\infty-bus'},'Location','east')
ylabel('\delta\theta_{PLL} [rad]');
xlabel('Time [s]');

%Figure 11: Plot qm during step response. q = vod*iod+voq*ioq
figure(11);
%plot(t4_1,-y4_1(:,3).*y4_1(:,12)+y4_1(:,4).*y4_1(:,11));
plot(t4_1_ext,y4_1_ext(:,19),t4_1,y4_1(:,19));
axis([0 10 .015 .1]);
legend({'Y-bus','\infty-bus'},'Location','east')
title('Reactive power (with stepped p ref)');
ylabel('q_{m} [pu]')
xlabel('Time [s]');

%Figure 12: Plot power during freq ramp. p = vod*iod+voq*ioq
figure(12);
plot(t4_2_ext,y4_2_ext(:,3).*y4_2_ext(:,11)+y4_2_ext(:,4).*y4_2_ext(:,12),t4_2,y4_2(:,3).*y4_2(:,11)+y4_2(:,4).*y4_2(:,12));
axis([0 10 0.4 0.7]);
legend({'Y-bus','\infty-bus'},'Location','east')
title('Power [pu] (with freq ramp down)');
ylabel('p [pu]');
xlabel('Time [s]');

%Figure 13: Plot converter current during freq ramp
figure(13);
plot(t4_2_ext,y4_2_ext(:,5),t4_2_ext,y4_2_ext(:,6),t4_2,y4_2(:,5),t4_2,y4_2(:,6));
axis([0 10 -0.1 0.8]);
legend({'i_{cv,d} Y-bus','i_{cv,q} Y-bus','i_{cv,d} \infty-bus','i_{cv,q} \infty-bus'},'Location','east')
title('Converter current (with freq ramp down)');
ylabel('i_{cv} [pu]');
xlabel('Time [s]');

%For D'Arco EPSR 122 (2015), Section 4.1
%"Response to change in loading"
function inverter_params = p_ref_step(t,inverter_params)
    if t<1
        inverter_params.p_ref = 0.5;
    else
        inverter_params.p_ref = 0.7;
    end
end

%For D'Arco EPSR 122 (2015), Section 4.2
%"Response to change in the grid frequency"
function inverter_params = wg_ramp(t,inverter_params)
    if t<1
        inverter_params.wg = 1;
    elseif (t<2)
        inverter_params.wg = 1-(0.005*(t-1)); % At t=2, 1-0.005 = .995
    else
        inverter_params.wg = 0.995;
    end
end