%% First let's try a simple first order ODE (not DAE):
tspan = [0, 1];
y0 = 1;

[t,y] = ode15s(@firstorder,tspan,y0);
plot(t,y)

%% swing_one
% one bus model

tspan = [0:0.1:10];
% initial conditions matter...
y0 = [1, 0, 1];

% mass matrix is 2x2 identy in this simple case
M = zeros(3);
M(1,1) = 1;
M(2,2) = 1;
options = odeset('Mass', M);  

[t,y] = ode15s(@swing_test,tspan,y0,options);
figure()
plot(t,y(:,:))
title('Time Series Plot of Rotor Angle, Speed, and Electrical Power');
legend('\omega', '\delta', 'P_e');
xlabel('Time (s)');
ylabel('Per Unit');



figure()
plot(y(:,1),y(:,3))
title('Rotor Speed vs. Electrical Power');
xlabel('Rotor Speed (pu)');
ylabel('Electrical Power (pu)');   
    

%% swing_two
tspan = [0, 20];
y0 = [0, 1, 0, 1.1, 0];

% mass matrix is 5x5...
M = eye(5);
% but the last entry is a zero
M(5,5) = 0;
options = odeset('Mass',M);


[t,y] = ode15s(@swing_two, tspan,y0,options);
plot(t,y(:,:))

legend('\omega_1', '\delta_1', '\omega_2', '\delta_2', 'line flow')


