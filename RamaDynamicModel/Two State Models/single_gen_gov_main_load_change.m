tspan = [0:0.1:10];
tspan_2 = [5:0.1:10];
y0 = [1, 0, 1, 0, 1, 1, 1];

% mass matrix
M = zeros(7);
M(1,1) = 1;
M(2,2) = 1;
M(4,4) = 1;
options = odeset('Mass', M);  

[t,y] = ode15s(@single_gen_test,tspan,y0,options);
% [t2,y2] = ode15s(@single_gen_test_2,tspan_2,y1(end,:),options);
% y = [y1;y2];
% t = [t1;t2];
figure()
% subplot(2,2,1);
plot(t,y(:,1:3))
title('Time Series Plot of Rotor Angle, Speed, and Electrical Power');
legend('\omega', '\delta', 'P_e');
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
v_g1 = 1;
v_s = 1;
z = 0.5;
W_s = 1;
theta_s = 0;
angCon = 2*pi*60;



%Type 2 governor data eq 16.8
x_g1 = y(4);
t_m_hat = y(5);
t_m = y(6);
w_ref = y(7);

t_max = 1.2;
t_min = 0.3;
t_m0 = 1.0;
R = 0.03;
T1 = 0.01;
T2 = 0.01;
w_0_ref = 1;
t_m_tilda = t_m0;

P_load_1 = 0.5;

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


%gen_eq1 -- x
gen_eq1 = 1/M1 *(t_m - P_e1 - D1*(w1-W_s));
gen_eq2 = angCon*(w1-W_s);


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


pf_eq1 = v_g1*v_s/z*sin(delta1 - theta_s) + P_load_1 - P_e1;


dydt = [
      gen_eq1; %DE
      gen_eq2; %DE
      pf_eq1;  %AE
      
      
      gov_eq1; %DE
      gov_eq2; %AE
      gov_eq3; %AE
      gov_eq4; %AE
      
%       vr_eq1;  %AE
%       vr_eq2;  %AE   
%       vr_eq3;  %DE
%       vr_eq4;  %DE      
%       vr_eq5;  %DE
%       vr_eq6;  %DE
      ];
end

function dydt = single_gen_test_2(t,y)

% this function captures the essentials of an oscillatory swing model.  The
% B coefficient parameterizes real power transfer to an infinite bus.  
w1 = y(1);
delta1 = y(2);
P_e1= y(3);


M1=2*2.9;    
D1=10;  
v_g1 = 1;
v_s = 1;
z = 0.5;
W_s = 1;
theta_s = 0;
angCon = 2*pi*60;



%Type 2 governor data eq 16.8
x_g1 = y(4);
t_m_hat = y(5);
t_m = y(6);
w_ref = y(7);

t_max = 1.2;
t_min = 0.3;
t_m0 = 1.0;
R = 0.02;
T1 = 0.01;
T2 = 0.01;
w_0_ref = 1;
t_m_tilda = t_m0;

P_load_1 = 1;



%gen_eq1 -- x
gen_eq1 = 1/M1 *(t_m - P_e1 - D1*(w1-W_s));
gen_eq2 = angCon*(w1-W_s);


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


pf_eq1 = v_g1*v_s/z*sin(delta1 - theta_s) + P_load_1 - P_e1;


dydt = [
      gen_eq1; %DE
      gen_eq2; %DE
      pf_eq1;  %AE
      
      
      gov_eq1; %DE
      gov_eq2; %AE
      gov_eq3; %AE
      gov_eq4; %AE
      ];
end