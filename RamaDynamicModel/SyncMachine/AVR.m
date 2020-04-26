function [dxdt] = AVR(x,params)
%AVR Automatic Voltage Regulator
%   This is the Type I AVR from Milano, a simplified DC Exciter

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

%Input Variables
v_f = x(1);
v_h = x(2);
v_ref = x(3);
v_m = x(4);
v_tilda_f = x(5);
v_r1 = x(6);
v_r2 = x(7);


dxdt = [
    % Algebraic Equations for all AVR (from Milano)
    v_tilda_f - v_f;
    v_ref_0 - v_ref;
    
    % Bus Voltage signal lag block
    (v_h - v_m)/T_r; %v_m/dt ; differential equation on the internal voltage the AVR is controlling
    
    %Specific Equations for the Type I AVR
    ( K_a * (v_ref - v_m - v_r2 - K_f / T_f * v_tilda_f) - v_r1) / T_a; % = v_dot_r1 ; differential
    -(K_f / T_f * v_tilda_f + v_r2) / T_f; %= v_dot_r2 ; differential
    -(v_tilda_f * (K_e + A_e * exp(B_e * abs(v_tilda_f)))-v_r1)/T_e;% = v_tilda_f/dt ; differential
    ];
end

