tspan = [0:0.1:20];
% initial conditions matter...
% y0 = [1, 0, 1];
y0 = [1, 0, 0.5];% 1, 0, -0.5];

% mass matrix is 2x2 identy in this simple case
M = zeros(3);
M(1,1) = 1;
M(2,2) = 1;
% M(4,4) = 1;
% M(5,5) = 1;
options = odeset('Mass', M);  

[t,y] = ode15s(@single_gen_test,tspan,y0,options);
figure()
% subplot(2,2,1);
plot(t,y(:,1:3))
title('Time Series Plot of Rotor Angle, Speed, and Electrical Power');
legend('\omega_1', '\delta_1', 'P_e_1');
xlabel('Time (s)');
ylabel('Per Unit');



function dydt = single_gen_test(t,y)

% this function captures the essentials of an oscillatory swing model.  The
% B coefficient parameterizes real power transfer to an infinite bus.  
w1 = y(1);
delta1 = y(2);
P_e1= y(3);


M1=2*2.9;    
D1=10;  
P_d1=1;
v_g1 = 1;
v_s = 1;
z =0.5;
W_s = 1;
theta_s = 0;
angCon = 2*pi*60;

r = 100;


dydt = [

    1/M1 *(P_d1 - P_e1 - D1*(w1-W_s));
    angCon*(w1-W_s);
    v_g1*v_s/z*sin(delta1 - theta_s) + v_g1^2/r - P_e1;
    ];
end