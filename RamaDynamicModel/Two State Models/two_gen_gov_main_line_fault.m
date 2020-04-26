tspan1 = [0:0.1:10];
tspan2 = [10:0.1:20];


y0 = [1;
0;
1;
0;
0;
1;
1;
1;
1;
0;
1;
0;
0;
1;
1;
1];

y0 = y0';

% mass matrix 
M = zeros(16);
M(1,1) = 1;
M(2,2) = 1;
M(5,5) = 1;
M(9,9) = 1;
M(10,10) = 1;
M(13,13) = 1;

options = odeset('Mass', M);  
%initialization ODE
[t1,y1] = ode15s(@two_gen_init,tspan1,y0,options);

%line fault ODE
[t2,y2] = ode15s(@two_gen_test,tspan2,y1(end,:),options);

%Combine results for plotting
y = [y1;y2];
t = [t1;t2];

%Plot results
figure('Name','two_gen_gov_main_corrected_pf');
subplot(2,2,1);
plot(t,y(:,[1:3,7,4]))
title('Time Series Plot of Rotor Angle, Speed, and Electrical Power');
legend('\omega_1', '\delta_1', 'P_{e_1}', 'P_{m_1}', 'P_{tf_1}');
xlabel('Time (s)');
ylabel('Per Unit');

% figure()
subplot(2,2,3);
plot(y(:,1),y(:,3))
title('Rotor Speed vs. Electrical Power');
xlabel('Rotor Frequency \omega_1 (pu)');
ylabel('Electrical Power P_e_1 (pu)');   

subplot(2,2,4);
plot(y(:,9),y(:,11))
title('Rotor Speed vs. Electrical Power');
xlabel('Rotor Frequency \omega_2 (pu)');
ylabel('Electrical Power P_e_2 (pu)');   


subplot(2,2,2);
plot(t,y(:,[9:11,15,12]))
title('Time Series Plot of Rotor Angle, Speed, and Electrical Power');
legend('\omega_2', '\delta_2', 'P_{e_2}', 'P_{m_2}', 'P_{tf_2}');
xlabel('Time (s)');
ylabel('Per Unit');
   



function dydt = two_gen_init(t,y)
%Gen 1 variables
w1 = y(1); 
delta1 = y(2);

%Bus 1 PF variables
P_e1 = y(3);
P_tf_1 = y(4);

%Gov 1 variables
x_g1 = y(5);
t_m_hat_1 = y(6);
t_m_1 = y(7);
w_ref_1 = y(8);

%Gen 2 variables
w2 = y(9);
delta2 = y(10);

%Bus 2 PF variables
P_e2 = y(11);
P_tf_2 = y(12);

%Gov 2 variables
x_g2 = y(13);
t_m_hat_2 = y(14);
t_m_2 = y(15);
w_ref_2 = y(16);


%Generator parameters
M1=2*2.9;   
M2=2*2.9;   
D1=10; 
D2=10; 
P_d1=1;
P_d2=1;
v_g1 = 1;
v_g2 = 1;
z =0.5;
W_s = 1;
angCon = 2*pi*60;

%Governor parameters
t_max = 1.2;
t_min = 0.3;
t_m0 = 1;
R = 0.03;
T1 = 0.01;
T2 = 0.01;
w_0_ref = 1;
t_m_tilda_1 = t_m0;
t_m_tilda_2 = t_m0;

%load parameters
P_load_1 = 1.1;
P_load_2 = 0.9;

%%
%generator 1 eqs
gen1_eq1 = 1/M1 *(t_m_1 - P_e1 - D1*(w1-W_s));
gen1_eq2 = angCon*(w1-W_s);
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
pf1_eq1 = P_tf_1 + P_load_1 - P_e1;
pf1_eq2 = v_g1*v_g2/z*sin(delta1 - delta2) - P_tf_1;

%%
%generator 2 eqs
%gen_eq1 -- x
gen2_eq1 = 1/M2 *(t_m_2 - P_e2 - D2*(w2-W_s));
gen2_eq2 = angCon*(w2-W_s);


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
pf2_eq1 = P_tf_2 + P_load_2 - P_e2;
pf2_eq2 = v_g1*v_g2/z*sin(delta2 - delta1) - P_tf_2;

% pf3_eq1 = P_load_1 + P_load_2 - P_e1 - P_e2;
% pf2_eq1 = v_g1*v_g2/z*sin(delta2 - delta1) + P_load_2 - P_e2;

%%

dydt = [
      gen1_eq1; %DE 1
      gen1_eq2; %DE 2
      
      pf1_eq1;  %AE 3
      pf1_eq2;  %AE 4
      
      gov1_eq1; %DE 5
      gov1_eq2; %AE 6
      gov1_eq3; %AE 7
      gov1_eq4; %AE 8
     
      gen2_eq1; %DE 9
      gen2_eq2; %DE 10
      
      pf2_eq1;  %AE 11
      pf2_eq2;  %AE 12
      
      gov2_eq1; %DE 13
      gov2_eq2; %AE 14
      gov2_eq3; %AE 15
      gov2_eq4; %AE 16
      

      
    ];
end

function dydt = two_gen_test(t,y)

% this function captures the essentials of an oscillatory swing model.  The
% B coefficient parameterizes real power transfer to an infinite bus.  

%Gen 1 variables
w1 = y(1); 
delta1 = y(2);

%Bus 1 PF variables
P_e1 = y(3);
P_tf_1 = y(4);

%Gov 1 variables
x_g1 = y(5);
t_m_hat_1 = y(6);
t_m_1 = y(7);
w_ref_1 = y(8);

%Gen 2 variables
w2 = y(9);
delta2 = y(10);

%Bus 2 PF variables
P_e2 = y(11);
P_tf_2 = y(12);

%Gov 2 variables
x_g2 = y(13);
t_m_hat_2 = y(14);
t_m_2 = y(15);
w_ref_2 = y(16);

%Generator parameters
M1=2*2.9;   
M2=2*2.9;   
D1=10; 
D2=10; 
P_d1=1;
P_d2=1;
v_g1 = 1;
v_g2 = 1;

%System parameters
z =0.25;
W_s = 1;
angCon = 2*pi*60;

%Governor parameters
t_max = 1.2;
t_min = 0.3;
t_m0 = 1;
R = 0.03;
T1 = 0.01;
T2 = 0.01;
w_0_ref = 1;
t_m_tilda_1 = t_m0;
t_m_tilda_2 = t_m0;

%load parameters
P_load_1 = 1.1;
P_load_2 = 0.9-0.001;

%%
%generator 1 eqs
gen1_eq1 = 1/M1 *(t_m_1 - P_e1 - D1*(w1-W_s));
gen1_eq2 = angCon*(w1-W_s);
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
pf1_eq1 = P_tf_1 + P_load_1 - P_e1;
pf1_eq2 = v_g1*v_g2/z*sin(delta1 - delta2) - P_tf_1;

%%
%generator 2 eqs
%gen_eq1 -- x
gen2_eq1 = 1/M2 *(t_m_2 - P_e2 - D2*(w2-W_s));
gen2_eq2 = angCon*(w2-W_s);


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
pf2_eq1 = P_tf_2 + P_load_2 - P_e2;
pf2_eq2 = v_g1*v_g2/z*sin(delta2 - delta1) - P_tf_2;

%%

dydt = [
      gen1_eq1; %DE 1
      gen1_eq2; %DE 2
      
      pf1_eq1;  %AE 3
      pf1_eq2;  %AE 4
      
      gov1_eq1; %DE 5
      gov1_eq2; %AE 6
      gov1_eq3; %AE 7
      gov1_eq4; %AE 8
     
      gen2_eq1; %DE 9
      gen2_eq2; %DE 10
      
      pf2_eq1;  %AE 11
      pf2_eq2;  %AE 12
      
      gov2_eq1; %DE 13
      gov2_eq2; %AE 14
      gov2_eq3; %AE 15
      gov2_eq4; %AE 16
      

      
    ];
end