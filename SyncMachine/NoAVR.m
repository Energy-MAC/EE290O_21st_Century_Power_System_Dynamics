function [ dxdt ] = NoAVR(x,params)
%NoGovernor these equations will provide the mechanical power state (P_m)
%equation if there is no governor acting on it directly
%   Detailed explanation goes here

%parameter
v_f0=params.v_f0;

%Variable
v_f = x(1);

dxdt = [
    v_f0 - v_f; 
    ];
end

