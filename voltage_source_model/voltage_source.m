% M-file accepts two arguments: t and y
% returns column vector dy



function dy = voltage_source(x_inner_curr_loop, Ed, Eq, Pactual, Qg, Vt, theta_conv, params)
% Inputs, outputs, and params of state space rep:
    % Inputs: [iq, id] (from inner_current_loop) 
    % Intermediate states: 
    % Outputs: Ed, Eq
   
% -----------------------------------------------

%get reference parameters
Rf = params.Rf;
Xf = params.Xf;

iq = x_inner_curr_loop(1);  % s6 = iq
id = x_inner_curr_loop(2);  % s7 = id

%need to calculate Vtd, Vtq
% Vtd = (Pactual+Qg)/(2*id);
% Vtq = (Pactual-Qg)/(2*iq);

Vtd = Vt*cos(theta_conv);
Vtq = Vt*sin(theta_conv); 

dy = [
    
    %%% Algebraic equations: 
    
    % 0 = 
    Vtd + id*Rf - iq*Xf - Ed;
    
    % 0 = 
    Vtq + iq*Rf + id*Xf - Eq;

];
