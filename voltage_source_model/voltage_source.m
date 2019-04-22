% M-file accepts two arguments: t and y
% returns column vector dy



function dy = voltage_source(x_volt_source,  params)
% Inputs, outputs, and params of state space rep:
    % Inputs: [iq, id] (from power_controller) 
    % States: 
    % Outputs: 
   
% -----------------------------------------------

%get reference parameters
%x_inner_curr_loop is an array that holds the states s6 - s7 as written in the
%Rama thesis

dy = [
    %%% Differential equations:
    
    %ds8/dt = 
    (1/Ted)*(Ed - s8);
    
    %ds9/dt = 
    (1/Teq)*(Eq-s9);

];
