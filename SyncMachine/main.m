

%% Two Axis Model Connected to an Infinte Bus
% one bus model
parameters
params = {SM_params, InfBus_params};

tspan = [0:0.1:10];

%The Variables in all their glory (for Reference)
% w = x(1);
% delta = x(2);
% eprime_d = x(3);
% eprime_q = x(4);
% P_e= x(5);
% i_q = x(6);
% i_d = x(7);
% v_q = x(8);
% v_d = x(9);
% v_f = x(10);
% P_m = x(11);
% v_h = x(12);
% theta_h = x(13);
% P_h = x(14);
% Q_h = x(15);

% initial conditions matter...
y0 = [ 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0.9, 1, 0, 1, 0 ];

y00 = fsolve(@(y)InfBus_to_2axis(0,y,params),y0);
y0 = round(y00,1); %perturb the initial conditions

% mass matrix is 15x15 identy in this simple case
M = zeros(15);
M(1,1) = 1;
M(2,2) = 1;
M(3,3) = 1;
M(4,4) = 1;
options = odeset('Mass', M);  

[t,y] = ode15s(@(t,y)InfBus_to_2axis(t,y,params),tspan,y0,options);
figure(1)
plot(t,y(:,[1,2,14,15]))
title('Time Series Plot of Rotor Angle, Speed, and Electrical Power');
legend('\omega', '\delta', 'P_h','Q_h');
xlabel('Time (s)');
ylabel('Per Unit');



figure(2)
plot(y(:,1),y(:,5))
title('Rotor Speed vs. Electrical Power');
xlabel('Rotor Speed (pu)');
ylabel('Electrical Power (pu)');   

figure(3)
plot(y(:,1),y(:,14))
title('Rotor Speed vs. Generator Power Out');
xlabel('Rotor Speed (pu)');
ylabel('Generator Power (pu)');   