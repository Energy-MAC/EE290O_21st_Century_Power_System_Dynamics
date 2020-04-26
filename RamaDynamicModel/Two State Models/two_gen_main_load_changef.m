%time spans for testing
tspan = [0:0.1:10];
tspan_2 = [10:0.1:20];

y0 = [
 1;  % w1 = y(1); 
 0;  % delta1 = y(2);
 1;  % P_e1= y(3);
 1;  % w2 = y(4);
 0;  % delta2 = y(5);
 1;  % P_e2= y(6);
 0;  % P_tf_1 = y(7);
 0]; % P_tf_2 = y(8);


y0 = y0';

% mass matrix is 2x2 identy in this simple case
M = zeros(8);
M(1,1) = 1;
M(2,2) = 1;
M(4,4) = 1;
M(5,5) = 1;
options = odeset('Mass', M);  

%initialization ODE
[t1,y1] = ode15s(@single_gen_test,tspan,y0,options);

%load change ODE
[t2,y2] = ode15s(@single_gen_test_2,tspan_2,y1(end,:),options);

%Combine results for plotting
y = [y1;y2];
t = [t1;t2];

%Plot results
figure('Name','two_gen_main_corrected_pf');
subplot(2,2,1);
plot(t,y(:,[1:3,7]))
title('Time Series Plot of Rotor Angle, Speed, and Electrical Power');
legend('\omega_1', '\delta_1', 'P_{e_1}', 'P_{tf_1}');
xlabel('Time (s)');
ylabel('Per Unit');

% figure()
subplot(2,2,3);
plot(y(:,1),y(:,3))
title('Rotor Speed vs. Electrical Power');
xlabel('Rotor Frequency \omega_1 (pu)');
ylabel('Electrical Power P_e_1 (pu)');   

subplot(2,2,4);
plot(y(:,4),y(:,6))
title('Rotor Speed vs. Electrical Power');
xlabel('Rotor Frequency \omega_2 (pu)');
ylabel('Electrical Power P_e_2 (pu)');   


subplot(2,2,2);
plot(t,y(:,[4:6,8]))
title('Time Series Plot of Rotor Angle, Speed, and Electrical Power');
legend('\omega_2', '\delta_2', 'P_{e_2}', 'P_{tf_2}');
xlabel('Time (s)');
ylabel('Per Unit');
   



function dydt = single_gen_test(t,y)
%These are the states for the generators only modeling the mechanical dynamics  

%Gen 1
w1 = y(1); 
delta1 = y(2);
P_e1= y(3);

%Gen 2
w2 = y(4);
delta2 = y(5);
P_e2= y(6);

%Powerflow states
P_tf_1 = y(7);
P_tf_2 = y(8);

%Machine parameters
M1=2*2.9;   
M2=2*2.9;   
D1=10; 
D2=10; 
P_d1=1;
P_d2=1;
W_s = 1;

%System parameters
v_g1 = 1;
v_g2 = 1;
z =0.5;
angCon = 2*pi*60;


%Load Parameters
P_load_1 = 1.1;

P_load_2 = 0.9;


dydt = [
    
    %generator 1
    1/M1 *(P_d1 - P_e1 - D1*(w1-W_s));
    angCon*(w1-W_s);
    P_tf_1 + P_load_1 - P_e1;
    
    %generator 2
    1/M2 *(P_d2 - P_e2 - D2*(w2-W_s));
    angCon*(w2-W_s);
    P_tf_2 + P_load_2 - P_e2;
    
    v_g1*v_g2/z*sin(delta1 - delta2) - P_tf_1;
    v_g1*v_g2/z*sin(delta2 - delta1) - P_tf_2;
    ];
end


function dydt = single_gen_test_2(t,y)
%These are the states for the generators only modeling the mechanical dynamics  

%Gen 1
w1 = y(1); 
delta1 = y(2);
P_e1= y(3);

%Gen 2
w2 = y(4);
delta2 = y(5);
P_e2= y(6);

%Powerflow states
P_tf_1 = y(7);
P_tf_2 = y(8);

%Machine parameters
M1=2*2.9;   
M2=2*2.9;   
D1=10; 
D2=10; 
P_d1=1;
P_d2=1;
W_s = 1;

%System parameters
v_g1 = 1;
v_g2 = 1;
z =0.5;
angCon = 2*pi*60;


%Load Parameters
P_load_1 = 1.0;

P_load_2 = 1.0;



dydt = [
    
    %generator 1
    1/M1 *(P_d1 - P_e1 - D1*(w1-W_s));
    angCon*(w1-W_s);
    P_tf_1 + P_load_1 - P_e1;
    

    %generator 2
    1/M2 *(P_d2 - P_e2 - D2*(w2-W_s));
    angCon*(w2-W_s);
    P_tf_2 + P_load_2 - P_e2;
    
    v_g1*v_g2/z*sin(delta1 - delta2) - P_tf_1;
    v_g1*v_g2/z*sin(delta2 - delta1) - P_tf_2;
    ];
end