
% M-file accepts two arguments: t and y
% returns column vector dy



function dy = inner_current_loop(x_inner_curr_loop, IQcmd, IPcmd, params)
% Inputs, outputs, and params of state space rep:
    % Inputs: [IQcmd,IPcmd] (from power_controller) 
    % Intermediate States:
    % Outputs: [s6, s7] (in x_inner_curr_loop) = [id, iq]
   
% -----------------------------------------------

%get reference parameters
Tq = params.Tq;
Td = params.Td;

%x_inner_curr_loop is an array that holds the states s6 - s7 as written in the
%Rama thesis
s6 = x_inner_curr_loop(1);  % s6 = iq
s7 = x_inner_curr_loop(2);  % s7 = id

dy = [

    %%% Differential equations: 
    
    % ds6/dt =
    (1/Tq)*(IQcmd - s6);         % should this be -Iqcmd as in appendix b of Rama thesis

    % ds7/dt =
    (1/Td)*(IPcmd - s7);

];
end