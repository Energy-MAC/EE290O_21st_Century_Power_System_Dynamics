%% initial conditions for dynamical states
i_1dq0 = [-24e3,0];     % filter current, amps
i_odq0 = [-12.03e3,20.83e3];       % terminal current
v_cdq0 = [-20.78e3,12e3];        % filter voltage, 24 kV
gamma_dq0 = [0,(-12e3/30.4)];  % states for current PI controller
p_avg0 = 500e6;          % low-pass-filtered measurements of real power
q_avg0 = 50e6;          % low-pass-filtered measurements of reactive power
phi_pq0 = [-240e3,0];    % states for real and reactive power PI controllers
%v_PLL0 = 0;          % filtered d-axis voltage measurement, 24 kV
%phi_PLL0 = 0;        % PI compensator state for PLL
%delta_i0 = 0;        % angle for dq transformation
%delta_g0 = 2*pi/3;       % grid angle

x_i0 = [i_1dq0, i_odq0, v_cdq0, gamma_dq0, p_avg0, q_avg0, phi_pq0]';
% x = [i_1dq, i_odq, v_odq, gamma_dq, p_avg, q_avg, phi_pq, v_PLL, phi_PLL, delta_i]';

%options = optimoptions('fsolve','Display','iter');
%x_fsolve = fsolve(@testLCLcontrollers_fsolve, x_i0, options);


%% simple first order ODE

%tspan = [0,1];
tspan = linspace(0,1e-4,1000);
[t,x] = ode15s(@testLCLcontrollers, tspan, x_i0);

'finish'

R_c = 0.02;
%v_o = (i_1 - i_o)*R_c + v_c;
v_o = (x(:,1:2) - x(:,3:4))*R_c + x(:,5:6);

%% plots for LCL, current, and power controller

figure

subplot(2,2,1)
plot(t,x(:,9),t,x(:,10),'--','LineWidth',1)
%ylim([-10e7 10e7])
title('(a) low-pass filtered power measurements')
xlabel('time (s)'); ylabel('');
legend('p_{avg} (W)','q_{avg} (VAR)'); legend('boxoff');

subplot(2,2,2)
plot(t,x(:,11),t,x(:,12),'--','LineWidth',1)
ylim([-10e5 10e5])
title('(b) states for real and reactive power PI controllers')
xlabel('time (s)'); ylabel('');
legend('\phi_p (W)','\phi_q (VAR)'); legend('boxoff');

%p = 3/2 * (v_od * i_od + v_oq * i_oq);
%q = 3/2 * (v_oq * i_od - v_od * i_oq);
subplot(2,2,3)
plot(t,(3/2 * (x(:,5).*x(:,3) + x(:,6).*x(:,4))),t,(3/2 * (x(:,6).*x(:,3) + x(:,5).*x(:,4))),'LineWidth',1)
ylim([-10e9 10e10])
title('(c) real and reactive power delivered by the inverter')
xlabel('time (s)'); ylabel('');
legend('p (W)','q (VAR)'); legend('boxoff');

% gains of the power controller
k_PQp = 0.01;       % V^-1
k_PQi = 0.1;        % (V*s)^-1
p_star = 500e6;     %500e6;     % MW
q_star = 50e6; %50e6;      % MVAR
%i_1dqstar = k_PQp * dphi_pq + k_PQi * phi_pq;
%dphi_pq = [p_star, q_star]' - s_avg;

subplot(2,2,4)
plot(t,(k_PQp .* (p_star - x(:,9)) + k_PQi .* x(:,11)),t,(k_PQp .* (q_star - x(:,10)) + k_PQi .* x(:,12)),'LineWidth',1)
ylim([-10e6 10e6])
title('(d) i_1^{dq*}')
xlabel('time (s)'); ylabel('');
legend('p component','q component'); legend('boxoff');

%% plots for LCL and current controller, gamma_dq

figure

subplot(1,2,1)
plot(t,x(:,1),t,x(:,2),'LineWidth',1)
%ylim([-100000 100000])
title('(a) filter current')
xlabel('time (s)'); ylabel('amps');
legend('i_{1d}','i_{1q}'); legend('boxoff');

subplot(1,2,2)
plot(t,x(:,7),t,x(:,8),'LineWidth',1)
title('(b) states for current PI controller');
xlabel('time (s)'); ylabel('\gamma_{dq}');
legend('\gamma_d','\gamma_q'); legend('boxoff');

%v_idqstar = k_ip * dgamma_dq + k_ii * gamma_dq + [0, -1; 1, 0] * omega_PLL * L_f * i_1dq + v_odq;
%k_ip = 16.4;        % V/A
%k_ii = 30.4;        % V/(A*s)
%L_f = 1e-3;         % mH, inductance
%omega = 2*pi*60;


%% plots for LCL

figure

subplot(2,2,1)
plot(t,x(:,1),t,x(:,2),'LineWidth',1)
%ylim([-10e7 10e7])
title('(a) filter current')
xlabel('time (s)'); ylabel('amps');
legend('i_{1d}','i_{1q}'); legend('boxoff');

subplot(2,2,2)
plot(t,x(:,3),t,x(:,4),'LineWidth',1)
%ylim([-10e7 10e7])
title('(b) terminal current')
xlabel('time (s)'); ylabel('amps');
legend('i_{od}','i_{oq}'); legend('boxoff');

subplot(2,2,3)
plot(t,x(:,5),t,x(:,6),'LineWidth',1)
%ylim([-10e7 10e7])
title('(c) capacitor voltage')
xlabel('time (s)'); ylabel('volts');
legend('v_{cd}','v_{cq}'); legend('boxoff');

subplot(2,2,4)
plot(t,v_o(:,1),t,v_o(:,2),'LineWidth',1)
%ylim([-10e7 10e7])
title('(d) filter voltage')
xlabel('time (s)'); ylabel('volts');
legend('v_{od}','v_{oq}'); legend('boxoff');


%%
omega_PLL = 377;
L_f = 1e-3;
figure
plot(t,[0, -1; 1, 0] * omega_PLL * L_f * x(:,1),t,[0, -1; 1, 0] * omega_PLL * L_f * x(:,2))
xlabel('time (s)'); ylabel('i_dq');
legend('i_d','i_q'); legend('boxoff');
%%

subplot(2,3,5)
plot(t,v_o(:,1),t,v_o(:,2),'LineWidth',1)
%ylim([-1 2])
title('inverter voltage')
xlabel('time (s)'); ylabel('volts');
legend('v_{id}','v_{iq}'); legend('boxoff');


%% plots for PLL

figure

subplot(3,4,1)
plot(t,x(:,5),'LineWidth',1)
%ylim([-1 2])
title('filtered d-axis voltage measurement')
xlabel('time (s)'); ylabel('');
legend('v_{PLL}'); legend('boxoff');

subplot(3,4,2)
plot(t,x(:,6),'LineWidth',1)
%ylim([-1000000 1000000])
title('PI compensator state for PLL')
xlabel('time (s)'); ylabel('');
legend('phi_{PLL}'); legend('boxoff');

subplot(3,4,3)
plot(t,x(:,7),'LineWidth',1)
%ylim([-1000000 1000000])
title('angle for dq transformation')
xlabel('time (s)'); ylabel('radians');
legend('delta_i'); legend('boxoff');

subplot(3,4,4)
plot(t,x(:,8),'LineWidth',1)
%ylim([-1000000 1000000])
title('angle for grid transformation')
xlabel('time (s)'); ylabel('radians');
legend('delta_g'); legend('boxoff');

subplot(3,4,5)
plot(t(1:end-1),diff(x(:,5))./diff(t),'LineWidth',1)
%ylim([-1 2])
title('diff filtered d-axis voltage measurement')
xlabel('time (s)'); ylabel('(V)');
legend('dv_{PLL}'); legend('boxoff');

subplot(3,4,6)
plot(t(1:end-1),diff(x(:,6))./diff(t),'LineWidth',1)
%ylim([-1000000 1000000])
title('diff PI compensator state for PLL')
xlabel('time (s)'); ylabel('');
legend('dphi_{PLL}'); legend('boxoff');

subplot(3,4,7)
plot(t(1:end-1),diff(x(:,7))./diff(t),'LineWidth',1)
%ylim([-1000000 1000000])
title('diff angle for dq transformation')
xlabel('time (s)'); ylabel('radians');
legend('ddelta_i'); legend('boxoff');

subplot(3,4,8)
plot(t(1:end-1),diff(x(:,8))./diff(t),'LineWidth',1)
%ylim([-1000000 1000000])
title('diff angle for grid transformation')
xlabel('time (s)'); ylabel('radians');
legend('ddelta_g'); legend('boxoff');

subplot(3,4,9)
plot(t,24000*cos(x(:,8)-x(:,7)),'LineWidth',1)
%ylim([-1000000 1000000])
title('filter voltage = 24000*cos(delta_g-delta_i)')
xlabel('time (s)'); ylabel('(V)');
legend('v_{od}'); legend('boxoff');

subplot(3,4,10)
plot(t,24000*cos(x(:,8)),t,24000*cos(x(:,7)),'--','LineWidth',1)
%ylim([-1000000 1000000])
title('24000*cos(delta_g) and 24000*cos(delta_i)')
xlabel('time (s)'); ylabel('(V)');
legend('v_{oalpha}','v_{ialpha}'); legend('boxoff');

subplot(3,4,11)
plot(t,x(:,8)-x(:,7),'LineWidth',1)
%ylim([-1000000 1000000])
title('grid angle minus dq angle')
xlabel('time (s)'); ylabel('radians');
legend('delta_g - delta_i'); legend('boxoff');

subplot(3,4,12)
plot(t(1:end-1),diff(x(:,8))./diff(t)-diff(x(:,7))./diff(t),'LineWidth',1)
%ylim([-1000000 1000000])
title('diff grid angle minus diff dq angle')
xlabel('time (s)'); ylabel('radians');
legend('ddelta_g - ddelta_i'); legend('boxoff');
