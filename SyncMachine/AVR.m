function [dxdt] = AVR(x,params)
%AVR Automatic Voltage Regulator
%   This is a simple AVR, it takes in a 

%AVR number 2 from Milano, pg. 526
Vmax_r = params.Vmax_r; %pu
Vmin_r = params.Vmin_r; %pu
K_a = params.K_a; %pu/pu
T_a = params.T_a; %s
K_f = params.K_f; % s pu/pu
T_f = params.T_f; %s
K_e = params.K_e; %pu
T_e = params.T_e; %s
T_r = params.T_r; %s
A_e = params.A_e; %no units
B_e = params.B_e; %1/pu


end

