% Create connection between voltage source converter and infinite bus
% network

%x should be all states / variables (that change) that need to passed in 
%params are constant parameters

function inverter_dxdt = VoltageSource_InfBus(t,x,params)
% Number of states must equal number of DAEs in dxdt

% unpack states
% need to make sure this order matches that of inverter_dxdt arrays

x_pwr_ctrl = x(1:5);            % s1, s2, s3, s4, s5
IQcmd = x(6);                   % commanded q-component current
IPcmd = x(7);                   % commanded d-component current
x_inner_curr_loop = x(8:9);     % s6 (iq), s7 (id)
Ed = x(10);                     % d-component of E voltage source
Eq = x(11);                     % q-component of E voltage source
x_pwm_sw = x(12:13);              % s8, s9

%will have to change indices later when adding in modulation block
%Pline = x(14);                  % line real power
%Qline = x(15);                  % line reactive power

Vt = x(14);                     % terminal voltage
theta_conv = x(15);             % converter angle

Qg = x(16);                     % converter reactive power
Pactual = x(17);                % converter real power
omega = x(18);                  % converter angular freq

Ed_star = x(19);
Eq_star = x(20);

% include all all DAEs here
inverter_dxdt = [
    
    % Power Controller - generates Iqcmd and Ipcmd
    % 5 diff eqs: ds1/dt, ds2/dt, ds3/dt, ds4/dt, d5/dt
    % 2 alg eqs: IQcmd, IPcmd
    % 7 variables: s1, s2, s3, s4, s5 (all in x_pwr_ctrl), IQcmd, IPcmd
    
    % TODO: will get Vt, Qg, omega, Pactual from power flow equations? 
    power_controller(x_pwr_ctrl, Vt, Qg, omega, Pactual, IQcmd, IPcmd, params);    
      
    %Inner Current Loop - generates iq and id (s6 and s7)
    % 2 diff eqs: ds6/dt, ds7/dt
    % 0 alg eqns
    % 4 variables: s6, s7 (in x_inner_curr_loop), IQcmd, IPcmd
    inner_current_loop(x_inner_curr_loop, IQcmd, IPcmd, params);
    
    %Voltage Source Model - generates Ed and Eq
    % 0 diff eqns
    % 2 alg eqns: Ed, Eq
    % 4 variables: s6, s7, Ed, Eq
    voltage_source(x_inner_curr_loop, Ed, Eq, Pactual, Qg, Vt, theta_conv, params);
    
    %PWM Switching Delay - generates s8 and s9
    % 2 diff eqns: ds8/dt, ds9/dt
    % 0 alg eqns
    % 4 variables: s8, s9, Ed, Eq
    PWM_switching_delay(x_pwm_sw, Ed, Eq, params);
    
       
    %Infinite Bus - solves Power Flow Equations
    % 1 difff eqn: dtheta_conv/dt
    %% 2 alg eqns: Pline, Qline
     infBusNwk(Vt, theta_conv, omega, Qg, Pactual, x_inner_curr_loop, params);

     %PWM block - still need to figure out how to implement
    %PWM_block(t, Ed, Eq, omega, Ed_star, Eq_star, params)
    PWM_block_internal_states(t, x_pwm_sw, omega, Ed_star, Eq_star, params)
    
    %0;  % dVt/dt = 0
    
    
       
   ];

