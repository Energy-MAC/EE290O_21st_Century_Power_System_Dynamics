function [dxdt] = TurbGov(x,params)
%TURBGOV Summary of this function goes here
%   A simple type 2 turbine governor from Milano

%Governor Params from Milano for Machine #2, from table D.8.  Milano states
%in example 16.1 that he is using a Type II governor, but the parameters
%used to define it are the same as a Type I.  Here we assume that T_s and
%T_c are equivalent to the T_1 and T_2 parameters for the Type II,
%respectively.
R = params.R;%pu
T_s = params.T_s;%s
T_c = params.T_c;%s
T_3 = params.T_3;%s
T_4 = params.T_4;%s
T_5 = params.T_5;%s
Pmax = params.Pmax;%pu
Pmin = params.Pmin;%pu
w_ref_0 = params.W_ref;

%Input Variable Vector
w = x(1);
P_m = x(2);
x_g = x(3);
P_m_hat = x(4);
w_ref = x(5);

%If statement P_m_tilda for saturation block
if P_m_hat > Pmax
    P_m_tilda = Pmax;
elseif P_m_hat >= Pmin && P_m_hat <= Pmax
    P_m_tilda = P_m_hat;
elseif P_m_hat < Pmin
    P_m_tilda = Pmin;
end

dxdt = [
     %common Algebraic governor equations eq 16.5 & 16.6
    t_m_tilda - t_m;
    w_ref_0 - w_ref;
    
    %Governor Equations for Type II
    (1/R*(1-T_s/T_c)*(w_ref-w1)-x_g)/T2; % = x_g_dot ; Differential
	x_g + 1/R*T_s/T_c*(w_ref-w1)+t_m0-P_m_hat; % = 0; Algebraic
    ];
end

