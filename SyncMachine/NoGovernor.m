function [ dxdt ]= NoGovernor(x,params)
%NoGovernor these equations will provide the mechanical power state (P_m)
%equation if there is no governor acting on it directly
%   Detailed explanation goes here

%parameter
P_m0=params.P_m0;

%Variable
P_m = x(1);

dxdt = [
    P_m0 - P_m; %P_m0
    ];
end

