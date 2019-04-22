function dydt = swing_test(t,y)

% this function captures the essentials of an oscillatory swing model.  The
% B coefficient parameterizes real power transfer to an infinite bus.  
w = y(1);
delta = y(2);
% P_e = y(3);
% i_q = y(5);
% i_d = y(6);
% v_h = y(7);
% p_h = y(8);
% q_h = y(9);
M=0.1;    
D=0.1;  
P_d=0.7;
P_e= y(3);
v_g = 1;
v_s = 1;
z = 0.05;
W_s = 1;
theta_s = 1;
dydt = [
    %omega dot - change in angular speed (eq 15.5 part 1)
%     1/M *(P_d - P_e - D*(w)); 
    1/M *(P_d - P_e - D*(w-W_s)); 
    %delta dot - change in torque (eq 15.5 part 2)
    377*(w-W_s);
    v_g*v_s/z*sin(w - theta_s) - P_e;
%     % Algebraic equations
%     % t_e electrical torque | t_e = (eq. 15.6)
%     psi_d*i_q - psi_q*i_d-t_e;
%     % auxiliary equations
%     %mechanical torque | 0 = (eq 15.7)
%     t_m_0 - t_m;
%     % field voltage | 0 = (eq 15.8)
%     v_f_0 - v_f;
%     % real power injection | p_h = (eq 15.2)
%     v_d*i_d + v_q*i_q-p_h;
%     % reactive power injection | q_h = (eq 15.3)
%     v_q*i_d - v_d*i_q-q_h;
    % system phasor voltage | 0 = (eq 15.4)
%     v_h*sin(delta - theta_h) - v_d;
%     v_h*cos(delta - theta_h) -v_q
    ];

% %data from appendix D machine 1
% r_a = 0;
% p_m = 0.9;
% D = 2;
% H = 5.148;
% x_trans_d = 0.2995;
% W_s = 1;
% e_trans_q = 1;
% M = 2*H;
% % p_h = 0.9;
% % q_h = 0.4359;
% p_e = p_h;
% 
% v_d = 1;
% v_q = 1;
% theta_h = 0.9; 
% 
% dydt = [
%     %equations from (eq 15.37) with delta_dot and omega_dot swapped
%     %omega dot
%     (p_m - p_e - D*(w-W_s))/M; 
%     %delta dot
%     377*(w-W_s);
%     % Algebraic equations
%     (v_q + r_a*i_q)*i_q + (v_d + r_a*i_d)*i_d-p_e;
%     v_q + r_a*i_q - e_trans_q + x_trans_d*i_d;
%     v_d + r_a*i_d - x_trans_d*i_q;
%     v_h*sin(delta - theta_h) - v_d;
%     v_h*cos(delta - theta_h) - v_q;
%     v_d*i_d + v_q*i_q-p_h;
%     v_q*i_d - v_d*i_q-q_h
%     ];

% % Two-Axis
% dydt = [
%     %omega dot - change in angular speed
%     1/M *(P_d - P_e - D*(w-W_s)); 
%     %delta dot - change in torque
%     377*(w-W_s);
%     %e'q dot - change in quadrature EMF
%     (-e_trans_q - (x_d - x_trans_d)*i_d + v_f)/T_trans_d_0;
%     %e'd dot - change in direct EMF
%     (-e_trans_d + (x_q - x_trans_q)*i_q)/T_trans_q_0
%     %algebraic equations
%     v_q + r_a*i_q - e_trans_q + x_trans_d*i_d;
%     v_d + r_a*i_d - e_trans_d - x_trans_q*i_q;
%     ];