function dzdt = ode_full_system_closed_loop(t,z,param_plant,param_cntr,param_limits_plant,param_limits_cntr)

x_plant = z(1:param_plant.num_states); % Plant states
x_cntr = z(param_plant.num_states+1:end); % Controller states

% Get derivative of controller states, and 'u' vector from feedback
% controller
[dx_cntr_dt, u] = feedback_control(t,x_cntr,x_plant,param_cntr,param_plant,param_limits_cntr,param_limits_plant);

% Pass control into the plant
dx_plant_dt = ode_full_system_modular(t,x_plant,u,param_plant,param_limits_plant);

%Stack plant and controller states
dzdt = [dx_plant_dt;dx_cntr_dt];