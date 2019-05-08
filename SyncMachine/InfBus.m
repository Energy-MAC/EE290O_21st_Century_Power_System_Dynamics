function [ InfBus_dxdt ] = InfBus(x,params)

%The Parameters
X = params.X; %Reactance of the line to the infinte bus.
W_S = params.W_s;
v_s = params.v_s; %Initial Voltage magnitude of the system
theta_s = params.theta_s; %Voltage angle of the infinite bus

%The Variables
% w = x(1);
% delta = x(2);
% eprime_d = x(3);
% eprime_q = x(4);
% P_e= x(5);
% i_q = x(6);
% i_d = x(7);
% v_q = x(8);
% v_d = x(9);
% v_f = x(10);
% P_m = x(11);
v_h = x(1);%x(12);
theta_h = x(2);%x(13);
P_h = x(3);%x(14);
Q_h = x(4);%x(15);

InfBus_dxdt = [
    v_h*v_s/X*sin(theta_h - theta_s) - P_h; %Real Power Flow
    v_h*v_s/X*cos(theta_h - theta_s) - Q_h; %Reactive Power Flow
    ];