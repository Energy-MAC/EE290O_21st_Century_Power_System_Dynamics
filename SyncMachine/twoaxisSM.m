function [ SM_dxdt ] = twoaxisSM(x,params)%, cntrl)

%The Parameters
M=params.M; %Machine starting time = 2H; % H %Inertia constant [MVA]
D=params.D; % Damping Constant 
W_s = params.W_s; %Reference Frequency in per unit
freq_rads = params.freq_s*2*pi(); %system reference frequency in hertz is converted to rad/s per second
r_a = params.r_a; %armature resistance [pu]
x_d = params.x_d; % d-axis synchronous reactance
xprime_d = params.xprime_d; % d-axis transient reactance
x_q = params.x_q; % q-axis synchronous reactance
xprime_q = params.xprime_q; % q-axis transient reactance
Tprime_d0 = params.Tprime_d0;%d-axis open circuit transient time constant
Tprime_q0 = params.Tprime_q0;%q-axis open circuit transient time constant

%parameters to be replaced by control inputs
P_m0=params.P_m0;
v_f0 = params.v_f0;

% %Control Inputs:
% v_f0 = cntrl.v_f; % Field Voltage
% P_m0 = cntrl.v_f; % Mechanical Power (we could change this to torque, and multiply by x)


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
v_f = x(10);
P_m = x(11);
v_h = x(12);
theta_h = x(13);
P_h = x(14);
Q_h = x(15);



SM_dxdt = [
    %omega dot - change in angular speed (eq 15.5 part 1)
    1/M *(P_m - P_e - D*(w-W_s)); %assumes w = 1, so w*tau_m = tau_m = P_m
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
    %P_m0 - P_m; %This is replaced by
    %v_f0-v_f;
    
    %v_g*v_s/X*sin(delta - theta_s) - P_e;
    
    %Arbitrary automatic voltage regulator and 
    
    ];