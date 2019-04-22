% Create connection between voltage source converter and infinite bus
% network

%x should be all states / variables (that change) that need to passed in 
%params are constant parameters

function inverter_dxdt = VoltageSource_InfBus(t,x,params)
% Number of states must equal number of DAEs in dxdt

% unpack states
% need to make sure this order matches that of inverter_dxdt array
x_pwr_ctrl = x(1:5);            % s1, s2, s3, s4, s5
x_inner_curr_loop = x(6:7);     % s6 (iq), s7 (id)
x_pwm_sw = x(8:9);              % s8, s9
Vt = x(10);                     % terminal voltage
Qg = x(11);                     % reactive power
omega = x(12);                  % angular frequency
Pactual = x(13);                % actual angular frq
Qcmd = x(14);                   % commanded reactive power
Pcmd = x(15);                   % commanded real power
Iqcmd = x(16);                  % commanded q-component current
Ipcmd = x(17);                  % commanded d-component current
Ed = x(18);                     % d-component of E voltage source
Eq = x(19);                     % q-component of E voltage source

    % include all all DAEs here
inverter_dxdt = [
    
    % Power Controller - generates Iqcmd and Ipcmd
    % 5 diff eqs: ds1/dt, ds2/dt, ds3/dt, ds4/dt, d5/dt
    % 2 alg eqs: Qcmd, Pcmd
    % 7 variables: s1, s2, s3, s4, s5 (all in x_pwr_ctrl), Qcmd, Pcmd %is this
    % right? 
    power_controller(x_pwr_ctrl, Vt, Qg, omega, Pactual, Qcmd, Pcmd, Iqcmd, Ipcmd, params);    %do we need to add Qcmd, Pcmd here? 
    
    0;  %dQcmd = 0 (alg eqn)
    0;  %dPcmd = 0 (alg eqn)
    
    
    %Inner Current Loop - generates iq and id (s6 and s7)
    % 2 diff eqs: ds6/dt, ds7/dt
    % 0 alg eqns
    % 2 variables: s6, s7 (in x_inner_curr_loop)
    inner_current_loop(x_inner_curr_loop, Iqcmd, Ipcmd, params);
    
    %Voltage Source Model - generates Ed and Eq
    % 0 diff eqns
    % 2 alg eqns: Ed, Eq
    % 4 variables: s6, s7, Ed, Eq
    voltage_source(x_inner_curr_loop, Ed, Eq, params);
    
    %PWM Switching Delay - generates s8 and s9
    % 2 diff eqns: ds8/dt, ds9/dt
    % 0 alg eqns
    % 4 variables: s8, s9, Ed, Eq
    PWM_switching_delay(x_pwm_sw, Ed, Eq, params)
    
    %PWM block - still need to figure out how to implement
    
    
    ];

