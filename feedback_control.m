function [dx_cntr_dt, u] = feedback_control(t,x_cntr,x_plant,param_cntr,param_plant,param_limits_cntr,param_limits_plant)

if (t > 50)
    %disp('Stop here') insert breakpoint here for debugging
end

%% AVR

% Get states for the AVR
x_avr = x_cntr(param_limits_cntr.x_avr_init : param_limits_cntr.x_avr_end);

% AVR needs the voltage at generator buses
v_bus = x_plant(param_limits_plant.v_buses_init : param_limits_plant.v_buses_end); % All bus voltages
v_gen_bus = param_plant.I_inc_gens'*v_bus; % Voltage at generator terminals / generator buses

% AVR control
[dx_avr_dt,i_f] = f_avr(x_avr, param_cntr.v_ref_gen, v_gen_bus, param_cntr.k_avr);

%% Turbine control

% Get frequency at each generator
omega_gen = x_plant(param_limits_plant.omega_gens_init : param_limits_plant.omega_gens_end);

% Get turbine controller state
x_turb = x_cntr(param_limits_cntr.x_turb_init : param_limits_cntr.x_turb_end);

% Turbine control
[dx_turb_dt,tau_m] = f_turbine_PI(x_turb,omega_gen, param_cntr.k_droop_p, param_cntr.k_droop_i);


%% Stack derivatives of controller states and u
dx_cntr_dt = [
    dx_turb_dt;
    dx_avr_dt;
];

u = [
    tau_m;%tau_m
    i_f; %i_f
];