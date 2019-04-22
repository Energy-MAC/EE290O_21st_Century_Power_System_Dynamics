% Create connection between voltage source converter and infinite bus
% network

%x should be all states / variables (that change) that need to passed in 
%params are constant parameters

function inverter_dxdt = VoltageSource_InfBus(x,params)

inverter_dxdt = [
    %all differential equations and DAEs
    
    power_controller()
    inner_current_loop()
    
    ];

