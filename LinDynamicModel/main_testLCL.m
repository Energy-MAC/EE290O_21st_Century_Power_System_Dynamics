% simple first order ODE
%tspan = [0,1];
tspan = linspace(0,0.025,1000);

% initial conditions for dynamical states < identify these via MatPower
i_1dq0 = [0,0];     % filter current, amps
i_odq0 = [0,0];       % terminal current
v_cdq0 = [0,24e3];        % filter voltage, 24 kV
%gamma_dq0 = [0,0];  % states for current PI controller
%p_avg0 = 0;          % low-pass-filtered measurements of real power
%q_avg0 = 5.2e6;          % low-pass-filtered measurements of reactive power
%phi_pq0 = [0,0];    % states for real and reactive power PI controllers
%v_PLL0 = 0;          % filtered d-axis voltage measurement, 24 kV
%phi_PLL0 = 0;        % PI compensator state for PLL
%delta_i0 = 0;        % angle for dq transformation
%delta_g0 = 2*pi/3;       % grid angle

x_i0 = [i_1dq0, i_odq0, v_cdq0]';
% x = [i_1dq, i_odq, v_odq, gamma_dq, p_avg, q_avg, phi_pq, v_PLL, phi_PLL, delta_i]';

[t,x] = ode15s(@testLCL, tspan, x_i0);

'finish'

%v_o = (i_1 - i_o)*R_c + v_c;
v_o = (x(:,1:2) - x(:,3:4))*R_c + x(:,5:6);


%% plots for LCL

figure

subplot(2,2,1)
plot(t,x(:,1),t,x(:,2),'LineWidth',1)
%ylim([-100000 100000])
title('(a) filter current')
xlabel('time (s)'); ylabel('amps');
legend('i_{1d}','i_{1q}'); legend('boxoff');

subplot(2,2,2)
plot(t,x(:,3),t,x(:,4),'LineWidth',1)
%ylim([-100000 100000])
title('(b) terminal current')
xlabel('time (s)'); ylabel('amps');
legend('i_{od}','i_{oq}'); legend('boxoff');

subplot(2,2,3)
plot(t,x(:,5),t,x(:,6),'LineWidth',1)
%ylim([-1 2])
title('(c) capacitor voltage')
xlabel('time (s)'); ylabel('volts');
legend('v_{cd}','v_{cq}'); legend('boxoff');

subplot(2,2,4)
plot(t,v_o(:,1),t,v_o(:,2),'LineWidth',1)
%ylim([-1 2])
title('(d) filter voltage')
xlabel('time (s)'); ylabel('volts');
legend('v_{od}','v_{oq}'); legend('boxoff');


%% plots for power controller

figure

subplot(1,2,1)
plot(t,x(:,1),t,x(:,2),'--','LineWidth',1)
%ylim([-1 2])
title('low-pass filtered power measurements')
xlabel('time (s)'); ylabel('');
legend('p_{avg} (W)','q_{avg} (VAR)'); legend('boxoff');

subplot(1,2,2)
plot(t,x(:,3),t,x(:,4),'--','LineWidth',1)
%ylim([-1 2])
title('states for real and reactive power PI controllers')
xlabel('time (s)'); ylabel('');
legend('phi_p (W)','phi_q (VAR)'); legend('boxoff');

