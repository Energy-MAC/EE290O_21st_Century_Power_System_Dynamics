
%tspan = [0,1];
tspan = linspace(0,20,1000);

% initial conditions for dynamical states: 0 1 1
delta_m0 = 0;
omega_m0 = 1;
p_e0 = 1;

% mass matrix for DAE 3x3, 1 1 0 on diagonal via options odeset 'Mass',
% zero indicates to matlab that it's not a diff eq but algebraic
mass = [1,0,0;0,1,0;0,0,0];
options = odeset('Mass',mass);

x_m0 = [delta_m0,omega_m0,p_e0]';

[t,x] = ode15s(@testmachine,tspan,x_m0,options);

'finish'

%% plots for machine - combined

figure
plot(t,x(:,1),t,x(:,2),t,x(:,3),'LineWidth',1)
%ylim([-100000 100000])
title('machine state variables')
xlabel('time (s)'); ylabel('p.u.');
legend('\delta_m (rotor angle)','\omega_m (frequency)','p_e (power)'); legend('boxoff');


%% plots for machine

figure

subplot(1,3,1)
plot(t,x(:,1),'LineWidth',1)
%ylim([-100000 100000])
title('machine rotor angle')
xlabel('time (s)'); ylabel('');
legend('delta_m'); legend('boxoff');

subplot(1,3,2)
plot(t,x(:,2),'LineWidth',1)
%ylim([-100000 100000])
title('machine frequency')
xlabel('time (s)'); ylabel('');
legend('omega_m'); legend('boxoff');

subplot(1,3,3)
plot(t,x(:,3),'LineWidth',1)
%ylim([-1 2])
title('power')
xlabel('time (s)'); ylabel('');
legend('p_e'); legend('boxoff');

