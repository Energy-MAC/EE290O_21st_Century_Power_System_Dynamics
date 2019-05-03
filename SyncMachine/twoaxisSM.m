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
P_m0=params.P_m;
v_f0 = params.v_f;

% %Control Inputs:
% v_f0 = cntrl.v_f; % Field Voltage
% P_m0 = cntrl.v_f; % Mechanical Power (we could change this to torque, and multiply by x)
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
eprime_d = x(3);
eprime_q = x(4);
P_e= x(5);
i_q = x(6);
i_d = x(7);
v_q = x(8);
v_d = x(9);
v_h = x(10);
theta_h = x(11);
p_h = x(12);
q_h = x(13);
v_f = x(14);

% %our shortcut to defining the bus interface (voltage):
% v_h = v_s;
% theta_h = theta_s;
% 
% % voltage at bus_h (eq 15.4)
% v_h*sin(delta - theta_h) - v_d;
% v_h*cos(delta - theta_h) - v_q;
% 
% %Power injections at bus h
% P_h = v_d*i_d+v_q*i_q;
% Q_h = v_q*i_d-v_d*i_q;

SM_dxdt = [
    %omega dot - change in angular speed (eq 15.5 part 1)
    1/M *(P_m - P_e - SM_Params.D*(w-W_s)); %assumes w = 1, so w*tau_m = tau_m = P_m
    %delta dot - change in torque (eq 15.5 part 2)
    freq_rads*(w-W_s);
    %eprime_d dot
    (-eprime_q - (x_d - xprime_d) * i_d + v_f)/Tprime_d0;
    %eprime_q dot
    (-eprime_d - (x_q - xprime_q) * i_q + v_f)/Tprime_q0;
    
    %Algebraic Equations
    (v_q+r_a*i_q)*i_q+(v_d+r_a*i_d)*i_d - P_e; %define P_e from the internal voltage and current
    v_h*sin(delta - theta_h) - v_d;
    v_h*cos(delta - theta_h) - v_q;
    v_q + r_a*i_q - eprime_q + xprime_d * i_d;
    v_d + r_a*i_d - eprime_d + xprime_q * i_q;
    v_d*i_d+v_q*i_q - P_h; %Real Power Injection at bus h from internal d-q power
    v_q*i_d-v_d*i_q - Q_h; %Reactive Power Injection at bus h from internal d-q power
    P_m0 - P_m; %P_m0
    v_f0-v_f;
    
    %v_g*v_s/X*sin(delta - theta_s) - P_e;
    
    %Arbitrary automatic voltage regulator and 
    
    ];