%time spans for testing
tspan = [0:0.1:10];
tspan_2 = [5:0.1:10];

% w1 = y(1);
% delta_1 = y(2);
% P_e1 = y(3);
% v_d1 = y(4);
% v_q1 = y(5);

% v_b1 = y(6);
% theta_b1 = y(7);
% i_d1 = y(8);
% i_q1 = y(9);

% P_tf = y(10);
% Q_tf = y(11);
% P_b1 = y(12);
% Q_b1 = y(13);
y0 = [
    1
    0;
    1;
    1;
    1;
    1;
    1;
    1;
    1;
 0.25;
  0.1;
    0;
    0;
    0;
    1;
    1; 
    1];


% mass matrix
M = zeros(17);
M(1,1) = 1;
M(2,2) = 1;
M(14,14) = 1;
options = odeset('Mass', M);  

%initialization ODE
[t,y] = ode15s(@single_gen_test,tspan,y0,options);

%load change ODE
[t2,y2] = ode15s(@single_gen_test_2,tspan_2,y1(end,:),options);

%Combine results for plotting
y = [y1;y2];
t = [t1;t2];

%Plot results
figure('Name','single_gen_gov_full_classic_main');
% subplot(2,2,1);
plot(t,y(:,[1:3]))
title('Time Series Plot of Rotor Angle, Speed, and Electrical Power');
legend('\omega', '\delta', 'P_e');
xlabel('Time (s)');
ylabel('Per Unit');



function dydt = single_gen_test(t,y)

%These are the states for the full classical model

w1 = y(1);
delta_1 = y(2);
P_e1 = y(3);
v_d1 = y(4);
v_q1 = y(5);

v_b1 = y(6);
theta_b1 = y(7);
i_d1 = y(8);
i_q1 = y(9);

P_tf = y(10);
Q_tf = y(11);
P_b1 = y(12);
Q_b1 = y(13);

%Generator parameters
M1=2*2.9;    
D1=10;  
v_s = 1;
z = 0.5;
W_s = 1;
theta_s = 0;
angCon = 2*pi*60;

r_a1 = 0;
e_prime_q1 = 1;
x_prime_d1 = 0.2995;


%Type 2 governor data eq 16.8
x_g1 = y(14);
t_m_hat = y(15);
t_m = y(16);
w_ref = y(17);

t_max = 1.2;
t_min = 0.3;
t_m0 = 1.0;
R = 0.03;
T1 = 0.0;%0.01;
T2 = 0.1;%0.01;
w_0_ref = 1;
t_m_tilda = t_m0;

P_load_1 = 0.5;
Q_load_1 = 0.0;


% %Type I AVR
% v_ref_0
% 
% 
% vr_eq1 = v_tilda_f - v_f;
% vr_eq2 = v_0_ref - v_ref;
% vr_eq3 = (v_s - v_m)/T_r;
% vr_eq4 = (K_a * (v_ref - v_m - v_r2 - K_f/T_f * v_tilda_f) - v_r1)/T_r;
% vr_eq5 = -(K_f/T_f * v_tilda_f + v_r2)/T_f;
% S_e = A_e * exp(B_e * abs(v_tilda_f));
% vr_eq6 = -(v_tilda_f * (K_e + S_e) - v_r1)/T_e;


%Generator equations
gen_eq1 = 1/M1 *(t_m - P_e1 - D1*(w1-W_s));
gen_eq2 = angCon*(w1-W_s);
gen_eq3 = (v_q1 + r_a1*i_q1)*i_q1 + (v_d1 + r_a1*i_d1)*i_d1 - P_e1;
gen_eq4 = v_q1 + r_a1*i_q1 - e_prime_q1 +x_prime_d1*i_d1;
gen_eq5 = v_d1 + r_a1*i_d1 - x_prime_d1*i_q1;
gen_eq6 = v_b1*sin(delta_1 - theta_b1) - v_d1;
gen_eq7 = v_b1*cos(delta_1 - theta_b1) - v_q1;
gen_eq8 = v_d1*i_d1 + v_q1*i_q1 - P_b1;
gen_eq9 = v_q1*i_d1 - v_d1*i_q1 - Q_b1;


%gov_eq1 -- x_g_dot = (1/R(1-T1/T2)(w_ref - w) - x_g)/T2
gov_eq1 = (1/R*(1-T1/T2)*(w_ref-w1)-x_g1)/T2;
%gov_eq2 -- t_m_hat = x_g + 1/R T1/T2 (w_ref-w) + t_m0
gov_eq2 = x_g1 + 1/R*T1/T2*(w_ref-w1)+t_m0-t_m_hat;
%If statement t_m_tilda (feeds into gov_eq3)
if t_m_hat > t_max
    t_m_tilda = t_max;
elseif t_m_hat >= t_min && t_m_hat <= t_max
    t_m_tilda = t_m_hat;
elseif t_m_hat < t_min
    t_m_tilda = t_min;
end
%common governor equations eq 16.5 & 16.6
gov_eq3 = t_m_tilda - t_m;
gov_eq4 = w_0_ref - w_ref;

%Powerflow equations
pf_eq1 = abs(v_b1)*abs(v_s)/z*sin(theta_b1 - theta_s)  - P_tf;
pf_eq2 = abs(v_b1)^2/z - abs(v_b1)*abs(v_s)/z*cos(theta_b1 - theta_s) - Q_tf;
pf_eq3 = P_tf + P_load_1 - P_b1;
pf_eq4 = Q_tf + Q_load_1 - Q_b1;


dydt = [
      gen_eq1; %DE 1
      gen_eq2; %DE 2
      gen_eq3; %AE 3
      gen_eq4; %AE 4
      gen_eq5; %AE 5
      gen_eq6; %AE 6
      gen_eq7; %AE 7
      gen_eq8; %AE 8
      gen_eq9; %AE 9
      
      pf_eq1;  %AE 10
      pf_eq2;  %AE 11
      pf_eq3;  %AE 12
      pf_eq4;  %AE 13
      
      
      gov_eq1; %DE 14
      gov_eq2; %AE 15
      gov_eq3; %AE 16
      gov_eq4; %AE 17
      
%       vr_eq1;  %AE
%       vr_eq2;  %AE   
%       vr_eq3;  %DE
%       vr_eq4;  %DE      
%       vr_eq5;  %DE
%       vr_eq6;  %DE
      ];
end

function dydt = single_gen_test_2(t,y)
%These are the states for the full classical model
w1 = y(1);
delta_1 = y(2);
P_e1 = y(3);
v_d1 = y(4);
v_q1 = y(5);

v_b1 = y(6);
theta_b1 = y(7);
i_d1 = y(8);
i_q1 = y(9);

P_tf = y(10);
Q_tf = y(11);
P_b1 = y(12);
Q_b1 = y(13);

%Generator parameters
M1=2*2.9;    
D1=10;  
v_s = 1;
z = 0.5;
W_s = 1;
theta_s = 0;
angCon = 2*pi*60;

r_a1 = 0;
e_prime_q1 = 1;
x_prime_d1 = 0.2995;


%Type 2 governor data eq 16.8
x_g1 = y(14);
t_m_hat = y(15);
t_m = y(16);
w_ref = y(17);

t_max = 1.2;
t_min = 0.3;
t_m0 = 1.0;
R = 0.03;
T1 = 0.0;%0.01;
T2 = 0.1;%0.01;
w_0_ref = 1;
t_m_tilda = t_m0;

P_load_1 = 1.0;
Q_load_1 = 0.1;


% %Type I AVR
% v_ref_0
% 
% 
% vr_eq1 = v_tilda_f - v_f;
% vr_eq2 = v_0_ref - v_ref;
% vr_eq3 = (v_s - v_m)/T_r;
% vr_eq4 = (K_a * (v_ref - v_m - v_r2 - K_f/T_f * v_tilda_f) - v_r1)/T_r;
% vr_eq5 = -(K_f/T_f * v_tilda_f + v_r2)/T_f;
% S_e = A_e * exp(B_e * abs(v_tilda_f));
% vr_eq6 = -(v_tilda_f * (K_e + S_e) - v_r1)/T_e;


%generator equations
gen_eq1 = 1/M1 *(t_m - P_e1 - D1*(w1-W_s));
gen_eq2 = angCon*(w1-W_s);
gen_eq3 = (v_q1 + r_a1*i_q1)*i_q1 + (v_d1 + r_a1*i_d1)*i_d1 - P_e1;
gen_eq4 = v_q1 + r_a1*i_q1 - e_prime_q1 +x_prime_d1*i_d1;
gen_eq5 = v_d1 + r_a1*i_d1 - x_prime_d1*i_q1;
gen_eq6 = v_b1*sin(delta_1 - theta_b1) - v_d1;
gen_eq7 = v_b1*cos(delta_1 - theta_b1) - v_q1;
gen_eq8 = v_d1*i_d1 + v_q1*i_q1 - P_b1;
gen_eq9 = v_q1*i_d1 - v_d1*i_q1 - Q_b1;


%gov_eq1 -- x_g_dot = (1/R(1-T1/T2)(w_ref - w) - x_g)/T2
gov_eq1 = (1/R*(1-T1/T2)*(w_ref-w1)-x_g1)/T2;
%gov_eq2 -- t_m_hat = x_g + 1/R T1/T2 (w_ref-w) + t_m0
gov_eq2 = x_g1 + 1/R*T1/T2*(w_ref-w1)+t_m0-t_m_hat;
%If statement t_m_tilda (feeds into gov_eq3)
if t_m_hat > t_max
    t_m_tilda = t_max;
elseif t_m_hat >= t_min && t_m_hat <= t_max
    t_m_tilda = t_m_hat;
elseif t_m_hat < t_min
    t_m_tilda = t_min;
end
%common governor equations eq 16.5 & 16.6
gov_eq3 = t_m_tilda - t_m;
gov_eq4 = w_0_ref - w_ref;

%powerflow equations
pf_eq1 = abs(v_b1)*abs(v_s)/z*sin(theta_b1 - theta_s)  - P_tf;
pf_eq2 = abs(v_b1)^2/z - abs(v_b1)*abs(v_s)/z*cos(theta_b1 - theta_s) - Q_tf;
pf_eq3 = P_tf + P_load_1 - P_b1;
pf_eq4 = Q_tf + Q_load_1 - Q_b1;


dydt = [
      gen_eq1; %DE 1
      gen_eq2; %DE 2
      gen_eq3; %AE 3
      gen_eq4; %AE 4
      gen_eq5; %AE 5
      gen_eq6; %AE 6
      gen_eq7; %AE 7
      gen_eq8; %AE 8
      gen_eq9; %AE 9
      
      pf_eq1;  %AE 10
      pf_eq2;  %AE 11
      pf_eq3;  %AE 12
      pf_eq4;  %AE 13
      
      
      gov_eq1; %DE 14
      gov_eq2; %AE 15
      gov_eq3; %AE 16
      gov_eq4; %AE 17
      
%       vr_eq1;  %AE
%       vr_eq2;  %AE   
%       vr_eq3;  %DE
%       vr_eq4;  %DE      
%       vr_eq5;  %DE
%       vr_eq6;  %DE
      ];
end