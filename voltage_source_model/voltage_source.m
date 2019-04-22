% M-file accepts two arguments: t and y
% returns column vector dy



function dy = voltage_source(x_inner_curr_loop, Ed, Eq, params)
% Inputs, outputs, and params of state space rep:
    % Inputs: [iq, id] (from inner_current_loop) 
    % States: 
    % Outputs: Ed, Eq
   
% -----------------------------------------------

%get reference parameters
Rf = parmams.Rf;
Xf = params.Xf;

id = x_inner_curr_loop(1);  % s6 = iq
iq = x_inner_curr_loop(2);  % s7 = id

%need to calculate Vtd, Vtq


dy = [
    
    %%% Algebraic equations: 
    
    % 0 = 
    Vtd + id*Rf - iq*Xf - Ed;
    
    % 0 = 
    Vtq + iq*Rf + id*Xf - Eq;

];
