function [ SM_dxdt ] = twoaxisSM(t,x,params, cntrl)

%The Parameters
M=params.M;    %Machine starting time = 2H
D=params.D;  
v_g = params.v_g;
v_s = params.v_s;
X = params.X;
W_s = params.W_s;
theta_s = params.theta_s;
freq_rads = params.freq_s*2*pi(); %system reference frequency in hertz is converted to rad/s per second

%parameters to be replaced by control inputs
P_m=params.P_m;
v_f = params.v_f;

% %Control Inputs:
% v_f = cntrl.v_f; % Field Voltage
% P_m = cntrl.v_f; % Mechanical Power (we could change this to torque, and multiply by x)
% 
% H %Inertia constant [MVA]
% r_a %armature resistance [pu]
% x_t % Leakage Reactance
% x_d % d-axis synchronous reactance
% xprime_d % d-axis transient reactance
% x_q % q-axis synchronous reactance
% xprime_q % q-axis transient reactance
% T_AA %d-axis additional leakage time constant
% Tprime_d0 %d-axis open circuit transient time constant
% Tprime_q0 %q-axis open circuit transient time constant
% alpha_p %Active power ratio at node
% alpha_q %Reactive power ratio at node

%Defining the variables
w = x(1);
delta = x(2);
P_e= x(3);
i_q = x(4);
i_d = x(5);
% v_h = x(7);
% p_h = x(8);
% q_h = x(9);

% %our shortcut to defining the bus interface (voltage):
% v_h = v_s;
% theta_h = theta_s;
% 
% % voltage at bus_h (eq 15.4)
% v_d = v_h*sin(delta - theta_h);
% v_q = v_h*cos(delta - theta_h);
% 
% %Power injections at bus h
% P_h = v_d*i_d+v_q*i_q;
% Q_h = v_q*i_d-v_d*i_q;

SM_dxdt = [
    %omega dot - change in angular speed (eq 15.5 part 1)
    1/M *(P_m - P_e - SM_Params.D*(w-W_s)); %assumes w = 1, so w*tau_m = tau_m = P_m
    %delta dot - change in torque (eq 15.5 part 2)
    freq_rads*(w-W_s);
    
    v_g*v_s/X*sin(delta - theta_s) - P_e;
    
    
    ];