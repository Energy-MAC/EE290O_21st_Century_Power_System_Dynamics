function [dxdt] = TurbGov(x,params)
%TURBGOV Summary of this function goes here
%   A simple turbine governor from Milano

%Governor Params from Milano for Machine #2, from table D.8
R = params.R;%pu
T_s = params.T_s;%s
T_c = params.T_c;%s
T_3 = params.T_3;%s
T_4 = params.T_4;%s
T_5 = params.T_5;%s
Pmax = params.Pmax;%pu
Pmin = params.Pmin;%pu

%The input vector
end

