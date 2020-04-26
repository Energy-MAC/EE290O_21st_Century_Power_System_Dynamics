%time spans for testing
tspan1 = [0:0.1:10];
tspan2 = [10:0.1:20];


y0 = [ 
 1;    % w1 = y(1); 
 0;    % delta_1 = y(2);
 1;    % P_e1 = y(3);
 1;    % v_q1 = y(4);
 1;    % v_d1 = y(5);
 1;    % v_b1 = y(6);
 0;    % theta_b1 = y(7);
 1;    % i_d1 = y(8);
 1;    % i_q1 = y(9);
 0;    % P_tf_1 = y(10);
 0;    % Q_tf_1 = y(11);
 1;    % P_b1 = y(12);
 0;    % Q_b1 = y(13);
 0;    % x_g1 = y(14);
 1;    % t_m_hat_1 = y(15);
 1;    % t_m_1 = y(16);
 1;    % w_ref_1 = y(17);

 1;     % w2 = y(18);
 0;     % delta_2 = y(19);
 1;     % P_e2 = y(20);
 1;     % v_q2 = y(21);
 1;     % v_d2 = y(22);
 1;     % v_b2 = y(23);
 0;     % theta_b2 = y(24);
 1;     % i_d2 = y(25);
 1;     % i_q2 = y(26);
 0;     % P_tf_2 = y(27);
 0;     % Q_tf_2 = y(28);
 1;     % P_b2 = y(29);
 0;     % Q_b2 = y(30);
 0;     % x_g2 = y(31);
 1;     % t_m_hat_2 = y(32);
 1;     % t_m_2 = y(33);
 1;     % w_ref_2 = y(34);
];

y0 = y0';


% mass matrix
M = zeros(34);
M(1,1) = 1;
M(2,2) = 1;
M(14,14) = 1;
M(18,18) = 1;
M(19,19) = 1;
M(31,31) = 1;

options = odeset('Mass', M);  

%initialization ODE
[t1,y1] = ode15s(@two_gen_init,tspan1,y0,options);

%load change ODE
[t2,y2] = ode15s(@two_gen_test,tspan2,y1(end,:),options);

%Combine results for plotting
y = [y1;y2];
t = [t1;t2];

%Plot results
figure('Name','two_gen_gov_classic_main_corrected_pf');
subplot(2,2,1);
plot(t,y(:,[1:3,16,10,6,7]))
% hold on
% plot(t,(y(:,16)-y(:,10)))
% hold off
title('Time Series Plot of Rotor Angle, Speed, and Electrical Power');
legend('\omega_1', '\delta_1', 'P_{e_1}', 'P_{m_1}', 'P_{tf_1}', 'V_{b_1}', '\theta_{b_1}');
xlabel('Time (s)');
ylabel('Per Unit');

% figure()
subplot(2,2,3);
plot(y(:,16),y(:,11))
title('Rotor Speed vs. Mechanical Power');
ylabel('Rotor Frequency \omega_1 (pu)');
xlabel('Electrical Power P_m_1 (pu)');   

subplot(2,2,4);
plot(y(:,18),y(:,20))
title('Rotor Speed vs. Electrical Power');
xlabel('Rotor Frequency \omega_2 (pu)');
ylabel('Electrical Power P_e_2 (pu)');   


subplot(2,2,2);
plot(t,y(:,[18:20,33,27, 23, 24]))
% hold on
% plot(t,(y(:,33)-y(:,27)))
% hold off
title('Time Series Plot of Rotor Angle, Speed, and Electrical Power');
legend('\omega_2', '\delta_2', 'P_{e_2}', 'P_{m_2}', 'P_{tf_2}', 'V_{b_2}','\theta_{b_2}');
xlabel('Time (s)');
ylabel('Per Unit');
   



function dydt = two_gen_init(t,y)

%These are the states for the full classical model

%Gen 1 variables
w1 = y(1); 
delta_1 = y(2);
P_e1 = y(3);
v_q1 = y(4);
v_d1 = y(5);
v_b1 = y(6);
theta_b1 = y(7);
i_d1 = y(8);
i_q1 = y(9);

%Bus 1 PF variables
P_tf_1 = y(10);
Q_tf_1 = y(11);
P_b1 = y(12);
Q_b1 = y(13);


%Gov 1 variables
x_g1 = y(14);
t_m_hat_1 = y(15);
t_m_1 = y(16);
w_ref_1 = y(17);

%Gen 2 variables
w2 = y(18);
delta_2 = y(19);
P_e2 = y(20);
v_q2 = y(21);
v_d2 = y(22);
v_b2 = y(23);
theta_b2 = y(24);
i_d2 = y(25);
i_q2 = y(26);

%Bus 2 PF variables
P_tf_2 = y(27);
Q_tf_2 = y(28);
P_b2 = y(29);
Q_b2 = y(30);


%Gov 2 variables
x_g2 = y(31);
t_m_hat_2 = y(32);
t_m_2 = y(33);
w_ref_2 = y(34);


%Generator parameters
M1=2*2.9;   
M2=2*2.9;   
D1=10; 
D2=10; 
r_a1 = 0;
r_a2 = 0;
e_prime_q1 = 1;
e_prime_q2 = 1;
x_prime_d1 = 0.2995;
x_prime_d2 = 0.2995;


%System parameters
z =0.5;
W_s = 1;
angCon = 2*pi*60;

%Governor Parameters
t_max = 1.2;
t_min = 0.3;
t_m0 = 1;
R = 0.03;
T1 = 0.0;%0.01;
T2 = 0.1;%0.01; 
w_0_ref = 1;
t_m_tilda_1 = t_m0;
t_m_tilda_2 = t_m0;

%Load parameters
P_load_1 = 0.75;
Q_load_1 = 0;

P_load_2 = 1.25;
Q_load_2 = 0;

%%
%generator 1 eqs
gen1_eq1 = 1/M1 *(t_m_1 - P_e1 - D1*(w1-W_s));
gen1_eq2 = angCon*(w1-W_s);


gen1_eq3 = (v_q1 + r_a1*i_q1)*i_q1 + (v_d1 + r_a1*i_d1)*i_d1 - P_e1;
gen1_eq4 = v_q1 + r_a1*i_q1 - e_prime_q1 +x_prime_d1*i_d1;
gen1_eq5 = v_d1 + r_a1*i_d1 - x_prime_d1*i_q1;
gen1_eq6 = v_b1*sin(delta_1 - theta_b1) - v_d1;
gen1_eq7 = v_b1*cos(delta_1 - theta_b1) - v_q1;
gen1_eq8 = v_d1*i_d1 + v_q1*i_q1 - P_b1;
gen1_eq9 = v_q1*i_d1 - v_d1*i_q1 - Q_b1;



%gov_eq1 -- x_g_dot = (1/R(1-T1/T2)(w_ref - w) - x_g)/T2
gov1_eq1 = (1/R*(1-T1/T2)*(w_ref_1-w1)-x_g1)/T2;
%gov_eq2 -- t_m_hat = x_g + 1/R T1/T2 (w_ref-w) + t_m0
gov1_eq2 = x_g1 + 1/R*T1/T2*(w_ref_1-w1)+t_m0-t_m_hat_1;
%If statement t_m_tilda (feeds into gov_eq3)
if t_m_hat_1 > t_max
    t_m_tilda_1 = t_max;
elseif t_m_hat_1 >= t_min && t_m_hat_1 <= t_max
    t_m_tilda_1 = t_m_hat_1;
elseif t_m_hat_1 < t_min
    t_m_tilda_1 = t_min;
end
%common governor equations eq 16.5 & 16.6
gov1_eq3 = t_m_tilda_1 - t_m_1;
gov1_eq4 = w_0_ref - w_ref_1;
%Power transfer equation
pf1_eq1 = P_tf_1 + P_load_1 - P_b1;
pf1_eq2 = abs(v_b1)*abs(v_b2)/z*sin(theta_b1 - theta_b2) - P_tf_1;
pf1_eq3 = abs(v_b1)^2/z - abs(v_b1)*abs(v_b2)/z*cos(theta_b1 - theta_b2) - Q_tf_1;
pf1_eq4 = Q_tf_1 + Q_load_1 - Q_b1;

%%
%generator 2 eqs
%gen_eq1 -- x
gen2_eq1 = 1/M2 *(t_m_2 - P_e2 - D2*(w2-W_s));
gen2_eq2 = angCon*(w2-W_s);

gen2_eq3 = (v_q2 + r_a2*i_q2)*i_q2 + (v_d2 + r_a2*i_d2)*i_d2 - P_e2;
gen2_eq4 = v_q2 + r_a2*i_q2 - e_prime_q2 +x_prime_d2*i_d2;
gen2_eq5 = v_d2 + r_a2*i_d2 - x_prime_d2*i_q2;
gen2_eq6 = v_b2*sin(delta_2 - theta_b2) - v_d2;
gen2_eq7 = v_b2*cos(delta_2 - theta_b2) - v_q2;
gen2_eq8 = v_d2*i_d2 + v_q2*i_q2 - P_b2;
gen2_eq9 = v_q2*i_d2 - v_d2*i_q2 - Q_b2;


%gov_eq1 -- x_g_dot = (1/R(1-T1/T2)(w_ref - w) - x_g)/T2
gov2_eq1 = (1/R*(1-T1/T2)*(w_ref_2-w2)-x_g2)/T2;
%gov_eq2 -- t_m_hat = x_g + 1/R T1/T2 (w_ref-w) + t_m0
gov2_eq2 = x_g2 + 1/R*T1/T2*(w_ref_2-w2)+t_m0-t_m_hat_2;
%If statement t_m_tilda (feeds into gov_eq3)
if t_m_hat_2 > t_max
    t_m_tilda_2 = t_max;
elseif t_m_hat_2 >= t_min && t_m_hat_2 <= t_max
    t_m_tilda_2 = t_m_hat_2;
elseif t_m_hat_2 < t_min
    t_m_tilda_2 = t_min;
end
%common governor equations eq 16.5 & 16.6
gov2_eq3 = t_m_tilda_2 - t_m_2;
gov2_eq4 = w_0_ref - w_ref_2;



%Power transfer equation
pf2_eq1 = P_tf_2 + P_load_2 - P_b2;
pf2_eq2 = abs(v_b1)*abs(v_b2)/z*sin(theta_b2 - theta_b1) - P_tf_2;
pf2_eq3 = abs(v_b2)^2/z - abs(v_b1)*abs(v_b2)/z*cos(theta_b2 - theta_b1) - Q_tf_2;
pf2_eq4 = Q_tf_2 + Q_load_2 - Q_b2;


%%

dydt = [
      gen1_eq1; %DE 1
      gen1_eq2; %DE 2
      gen1_eq3; %AE 3
      gen1_eq4; %AE 4
      gen1_eq5; %AE 5
      gen1_eq6; %AE 6
      gen1_eq7; %AE 7
      gen1_eq8; %AE 8
      gen1_eq9; %AE 9
      
      pf1_eq1;  %AE 10
      pf1_eq2;  %AE 11
      pf1_eq3;  %AE 12
      pf1_eq4;  %AE 13
      
      gov1_eq1; %DE 14
      gov1_eq2; %AE 15
      gov1_eq3; %AE 16
      gov1_eq4; %AE 17
     
      gen2_eq1; %DE 18
      gen2_eq2; %DE 19
      gen2_eq3; %AE 20
      gen2_eq4; %AE 21
      gen2_eq5; %AE 22
      gen2_eq6; %AE 23
      gen2_eq7; %AE 24
      gen2_eq8; %AE 25
      gen2_eq9; %AE 26
      
      pf2_eq1;  %AE 27
      pf2_eq2;  %AE 28
      pf2_eq3;  %AE 29
      pf2_eq4;  %AE 30
      
      gov2_eq1; %DE 31
      gov2_eq2; %AE 32
      gov2_eq3; %AE 33
      gov2_eq4; %AE 34
      
    ];
end

function dydt = two_gen_test(t,y)

%These are the states for the full classical model
%Gen 1 variables
w1 = y(1); 
delta_1 = y(2);
P_e1 = y(3);
v_q1 = y(4);
v_d1 = y(5);
v_b1 = y(6);
theta_b1 = y(7);
i_d1 = y(8);
i_q1 = y(9);

%Bus 1 PF variables
P_tf_1 = y(10);
Q_tf_1 = y(11);
P_b1 = y(12);
Q_b1 = y(13);


%Gov 1 variables
x_g1 = y(14);
t_m_hat_1 = y(15);
t_m_1 = y(16);
w_ref_1 = y(17);

%Gen 2 variables
w2 = y(18);
delta_2 = y(19);
P_e2 = y(20);
v_d2 = y(21);
v_q2 = y(22);
v_b2 = y(23);
theta_b2 = y(24);
i_d2 = y(25);
i_q2 = y(26);

%Bus 2 PF variables
P_tf_2 = y(27);
Q_tf_2 = y(28);
P_b2 = y(29);
Q_b2 = y(30);


%Gov 2 variables
x_g2 = y(31);
t_m_hat_2 = y(32);
t_m_2 = y(33);
w_ref_2 = y(34);


%Generator Parameters
M1=2*2.9;   
M2=2*2.9;   
D1=10; 
D2=10; 
r_a1 = 0;
r_a2 = 0;
e_prime_q1 = 1;
e_prime_q2 = 1;
x_prime_d1 = 0.2995;
x_prime_d2 = 0.2995;

%System Parameters
z =0.5;
W_s = 1;
angCon = 2*pi*60;

%Governor Parameters
t_max = 1.2;
t_min = 0.3;
t_m0 = 1;
R = 0.03;
T1 = 0.0;%0.01;
T2 = 0.1;%0.01;
w_0_ref = 1;
t_m_tilda_1 = t_m0;
t_m_tilda_2 = t_m0;

%Load parameters
P_load_1 = 1;
Q_load_1 = 0.1;

P_load_2 = 1.0;
Q_load_2 = 0.1;

%%
%generator 1 eqs
gen1_eq1 = 1/M1 *(t_m_1 - P_e1 - D1*(w1-W_s));
gen1_eq2 = angCon*(w1-W_s);


gen1_eq3 = (v_q1 + r_a1*i_q1)*i_q1 + (v_d1 + r_a1*i_d1)*i_d1 - P_e1;
gen1_eq4 = v_q1 + r_a1*i_q1 - e_prime_q1 +x_prime_d1*i_d1;
gen1_eq5 = v_d1 + r_a1*i_d1 - x_prime_d1*i_q1;
gen1_eq6 = v_b1*sin(delta_1 - theta_b1) - v_d1;
gen1_eq7 = v_b1*cos(delta_1 - theta_b1) - v_q1;
gen1_eq8 = v_d1*i_d1 + v_q1*i_q1 - P_b1;
gen1_eq9 = v_q1*i_d1 - v_d1*i_q1 - Q_b1;



%gov_eq1 -- x_g_dot = (1/R(1-T1/T2)(w_ref - w) - x_g)/T2
gov1_eq1 = (1/R*(1-T1/T2)*(w_ref_1-w1)-x_g1)/T2;
%gov_eq2 -- t_m_hat = x_g + 1/R T1/T2 (w_ref-w) + t_m0
gov1_eq2 = x_g1 + 1/R*T1/T2*(w_ref_1-w1)+t_m0-t_m_hat_1;
%If statement t_m_tilda (feeds into gov_eq3)
if t_m_hat_1 > t_max
    t_m_tilda_1 = t_max;
elseif t_m_hat_1 >= t_min && t_m_hat_1 <= t_max
    t_m_tilda_1 = t_m_hat_1;
elseif t_m_hat_1 < t_min
    t_m_tilda_1 = t_min;
end
%common governor equations eq 16.5 & 16.6
gov1_eq3 = t_m_tilda_1 - t_m_1;
gov1_eq4 = w_0_ref - w_ref_1;
%Power transfer equation
pf1_eq1 = P_tf_1 + P_load_1 - P_b1;
pf1_eq2 = abs(v_b1)*abs(v_b2)/z*sin(theta_b1 - theta_b2) - P_tf_1;
pf1_eq3 = abs(v_b1)^2/z - abs(v_b1)*abs(v_b2)/z*cos(theta_b1 - theta_b2) - Q_tf_1;
pf1_eq4 = Q_tf_1 + Q_load_1 - Q_b1;

%%
%generator 2 eqs
%gen_eq1 -- x
gen2_eq1 = 1/M2 *(t_m_2 - P_e2 - D2*(w2-W_s));
gen2_eq2 = angCon*(w2-W_s);

gen2_eq3 = (v_q2 + r_a2*i_q2)*i_q2 + (v_d2 + r_a2*i_d2)*i_d2 - P_e2;
gen2_eq4 = v_q2 + r_a2*i_q2 - e_prime_q2 +x_prime_d2*i_d2;
gen2_eq5 = v_d2 + r_a2*i_d2 - x_prime_d2*i_q2;
gen2_eq6 = v_b2*sin(delta_2 - theta_b2) - v_d2;
gen2_eq7 = v_b2*cos(delta_2 - theta_b2) - v_q2;
gen2_eq8 = v_d2*i_d2 + v_q2*i_q2 - P_b2;
gen2_eq9 = v_q2*i_d2 - v_d2*i_q2 - Q_b2;


%gov_eq1 -- x_g_dot = (1/R(1-T1/T2)(w_ref - w) - x_g)/T2
gov2_eq1 = (1/R*(1-T1/T2)*(w_ref_2-w2)-x_g2)/T2;
%gov_eq2 -- t_m_hat = x_g + 1/R T1/T2 (w_ref-w) + t_m0
gov2_eq2 = x_g2 + 1/R*T1/T2*(w_ref_2-w2)+t_m0-t_m_hat_2;
%If statement t_m_tilda (feeds into gov_eq3)
if t_m_hat_2 > t_max
    t_m_tilda_2 = t_max;
elseif t_m_hat_2 >= t_min && t_m_hat_2 <= t_max
    t_m_tilda_2 = t_m_hat_2;
elseif t_m_hat_2 < t_min
    t_m_tilda_2 = t_min;
end
%common governor equations eq 16.5 & 16.6
gov2_eq3 = t_m_tilda_2 - t_m_2;
gov2_eq4 = w_0_ref - w_ref_2;



%Power transfer equation
pf2_eq1 = P_tf_2 + P_load_2 - P_b2;
pf2_eq2 = abs(v_b1)*abs(v_b2)/z*sin(theta_b2 - theta_b1) - P_tf_2;
pf2_eq3 = abs(v_b2)^2/z - abs(v_b1)*abs(v_b2)/z*cos(theta_b2 - theta_b1) - Q_tf_2;
pf2_eq4 = Q_tf_2 + Q_load_2 - Q_b2;



%%

dydt = [
      gen1_eq1; %DE 1
      gen1_eq2; %DE 2
      gen1_eq3; %AE 3
      gen1_eq4; %AE 4
      gen1_eq5; %AE 5
      gen1_eq6; %AE 6
      gen1_eq7; %AE 7
      gen1_eq8; %AE 8
      gen1_eq9; %AE 9
      
      pf1_eq1;  %AE 10
      pf1_eq2;  %AE 11
      pf1_eq3;  %AE 12
      pf1_eq4;  %AE 13
      
      gov1_eq1; %DE 14
      gov1_eq2; %AE 15
      gov1_eq3; %AE 16
      gov1_eq4; %AE 17
     
      gen2_eq1; %DE 18
      gen2_eq2; %DE 19
      gen2_eq3; %AE 20
      gen2_eq4; %AE 21
      gen2_eq5; %AE 22
      gen2_eq6; %AE 23
      gen2_eq7; %AE 24
      gen2_eq8; %AE 25
      gen2_eq9; %AE 26
      
      pf2_eq1;  %AE 27
      pf2_eq2;  %AE 28
      pf2_eq3;  %AE 29
      pf2_eq4;  %AE 30
      
      gov2_eq1; %DE 31
      gov2_eq2; %AE 32
      gov2_eq3; %AE 33
      gov2_eq4; %AE 34
      
    ];
end