% M-file accepts two arguments: t and y
% returns column vector dy



function dy = PWM_switching_delay(x_pwm_sw, Ed, Eq, params)
% Inputs, outputs, and params of state space rep:
    % Inputs: [iq, id] (from power_controller) 
    % States: 
    % Outputs: 
   
% -----------------------------------------------

%get reference parameters
Ted = params.Ted;
Teq = params.Teq;

s8 = x_pwm_sw(1);  % s8 = delayed Eq
s9 = x_pwm_sw(2);  % s9 = delayed Ed


dy = [
    %%% Differential equations:
    
    %ds8/dt = 
    (1/Ted)*(Ed - s8);
    
    %ds9/dt = 
    (1/Teq)*(Eq - s9);
    
];
    
