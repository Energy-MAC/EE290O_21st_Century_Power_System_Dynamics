function dxdt = ode_full_system_modular(t,x, param)

% this function returns the whole differential equation system of Curi
% paper in a modular fashion


%% Load parameters

omega0 = param.omega0;
j = param.j;

Z_lines = param.Z_lines;
inv_L_lines = param.inv_L_lines;
E_inc = param.E_inc;

Y_buses = param.Y_buses;
inv_C_buses = param.inv_C_buses;

Z_loads = param.Z_loads;
inv_L_loads = param.L_loads;
I_inc_loads = param.I_inc_loads;

inv_M_gens = param.inv_M_gens;
D_gens = param.D_gens;
Ell_gens = param.Ell_gens;
Z_gens = param.Z_gens;
inv_L_gens = param.inv_L_gens;
I_inc_gens = param.I_inc_gens;

%% Obtain size of state vector

%AC states
i_gens_size = size(Z_gens,1); % number of current of gens variables (2*gens)
% i_conv_size = size(Z_conv,1) % number of current of conv vars (2*convs)
i_conv_size = 0;
i_loads_size = size(Z_loads,1); % number of current of loads variables (2*loads)
i_lines_size = size(Z_lines,1); %obtain number of current of lines variables (2*lines)
v_buses_size = size(Y_buses,1); %obtain number of voltage of buses variables (2*buses)

%DC states
theta_gens_size = size(inv_M_gens,1); %number of angle of gens variables (gens)
omega_gens_size = size(inv_M_gens,1); %number of freq of gens variables (gens)
% vdc_conv_size = size(G_conv,1); %number of vdc of convs variables (convs)
vdc_conv_size = 0;

%Split the y variable in its parts

v_buses = x(1:v_buses_size); 
i_lines = x(v_buses_size+1:end);


%Some particular case of input current at node 1.
i_in = zeros( size(Y_buses,1), 1);
i_in(1) = 100;

%Compute the derivatives using auxiliary functions
diff_v_buses = dv_buses_dt(v_buses, i_lines, inv_C_buses, Y_buses, E_inc, i_in); %Eq (3) Curi Paper
diff_i_lines = di_lines_dt(v_buses, i_lines, inv_L_lines, Z_lines, E_inc); %Eq (2) Curi Paper

%Stack the system
dxdt = [ 
    diff_v_buses;
    diff_i_lines];