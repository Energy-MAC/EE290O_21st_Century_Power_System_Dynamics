% simple first order ODE
%tspan = [0,1];
tspan = linspace(0,0.006*4,1000);

% initial conditions for dynamical states < identify these via MatPower
%i_1dq0 = [0,217];     % filter current, amps %change sign
%i_odq0 = [0,0];     % terminal current
%v_odq0 = [24000,0];        % filter voltage, 24 kV
%gamma_dq0 = [0,0];  % states for current PI controller
%p_avg0 = 0;          % low-pass-filtered measurements of real power
%q_avg0 = 5.2e6;          % low-pass-filtered measurements of reactive power
%phi_pq0 = [0,0];    % states for real and reactive power PI controllers
v_PLL0 = 0;          % filtered d-axis voltage measurement, 24 kV
phi_PLL0 = 0;        % PI compensator state for PLL
delta_i0 = 0;        % angle for dq transformation
delta_g0 = 2*pi/3;       % grid angle

x_i0 = [v_PLL0, phi_PLL0, delta_i0, delta_g0]';
% x = [i_1dq, i_odq, v_odq, gamma_dq, p_avg, q_avg, phi_pq, v_PLL, phi_PLL, delta_i]';

[t,x] = ode15s(@testPLL, tspan, x_i0);

'finish'

%% PLL plots

figure

subplot(3,4,1)
plot(t,x(:,1),'LineWidth',1)
%ylim([-1 2])
title('(a) filtered d-axis voltage measurement')
xlabel('time (s)'); ylabel('(V)');
legend('v_{PLL}'); legend('boxoff');

subplot(3,4,2)
plot(t,x(:,2),'LineWidth',1)
%ylim([-1000000 1000000])
title('(b) PI compensator state for PLL')
xlabel('time (s)'); ylabel('');
legend('phi_{PLL}'); legend('boxoff');

subplot(3,4,3)
plot(t,x(:,3),'LineWidth',1)
%ylim([-1000000 1000000])
title('(c) angle for dq transformation')
xlabel('time (s)'); ylabel('radians');
legend('delta_i'); legend('boxoff');

subplot(3,4,4)
plot(t,x(:,4),'LineWidth',1)
%ylim([-1000000 1000000])
title('(d) angle for grid transformation')
xlabel('time (s)'); ylabel('radians');
legend('delta_g'); legend('boxoff');

subplot(3,4,5)
plot(t(1:end-1),diff(x(:,1))./diff(t),'LineWidth',1)
%ylim([-1 2])
title('(e) diff filtered d-axis voltage measurement')
xlabel('time (s)'); ylabel('(V)');
legend('dv_{PLL}'); legend('boxoff');

subplot(3,4,6)
plot(t(1:end-1),diff(x(:,2))./diff(t),'LineWidth',1)
%ylim([-1000000 1000000])
title('(f) diff PI compensator state for PLL')
xlabel('time (s)'); ylabel('');
legend('dphi_{PLL}'); legend('boxoff');

subplot(3,4,7)
plot(t(1:end-1),diff(x(:,3))./diff(t),'LineWidth',1)
%ylim([-1000000 1000000])
title('(g) diff angle for dq transformation')
xlabel('time (s)'); ylabel('radians');
legend('ddelta_i'); legend('boxoff');

subplot(3,4,8)
plot(t(1:end-1),diff(x(:,4))./diff(t),'LineWidth',1)
ylim([376.9999 377.0001])
title('(h) diff angle for grid transformation')
xlabel('time (s)'); ylabel('radians');
legend('ddelta_g'); legend('boxoff');

subplot(3,4,9)
plot(t,24000*cos(x(:,4)-x(:,3)),'LineWidth',1)
%ylim([-1000000 1000000])
title('(i) filter voltage = 24000*cos(delta_g-delta_i)')
xlabel('time (s)'); ylabel('(V)');
legend('v_{od}'); legend('boxoff');

subplot(3,4,10)
plot(t,24000*cos(x(:,4)),t,24000*cos(x(:,3)),'--','LineWidth',1)
%ylim([-1000000 1000000])
title('(j) 24000*cos(delta_g) and 24000*cos(delta_i)')
xlabel('time (s)'); ylabel('(V)');
legend('v_{oalpha}','v_{ialpha}'); legend('boxoff');

subplot(3,4,11)
plot(t,x(:,4)-x(:,3),'LineWidth',1)
%ylim([-1000000 1000000])
title('(k) grid angle minus dq angle')
xlabel('time (s)'); ylabel('radians');
legend('delta_g - delta_i'); legend('boxoff');

subplot(3,4,12)
plot(t(1:end-1),diff(x(:,4))./diff(t)-diff(x(:,3))./diff(t),'LineWidth',1)
%ylim([-1000000 1000000])
title('(l) diff grid angle minus diff dq angle')
xlabel('time (s)'); ylabel('radians');
legend('ddelta_g - ddelta_i'); legend('boxoff');
