function dxdt = ode_init_cond(x, u, param, pl)

% this function returns the whole differential equation system of Curi
% paper in a modular fashion


%% Load parameters

%Base
omega0 = param.omega0;
j = param.j;

%Lines
Z_lines = param.Z_lines;
inv_L_lines = param.inv_L_lines;
E_inc = param.E_inc;

%Buses
Y_buses = param.Y_buses;
inv_C_buses = param.inv_C_buses;

%Loads
Z_loads = param.Z_loads;
inv_L_loads = param.L_loads;
I_inc_loads = param.I_inc_loads;

%Generators
inv_M_gens = param.inv_M_gens;
D_gens = param.D_gens;
Ell_gens = param.Ell_gens;
Z_gens = param.Z_gens;
inv_L_gens = param.inv_L_gens;
I_inc_gens = param.I_inc_gens;

% %Converters
% inv_Cdc_convs = param.Cdc_convs;
% Gdc_convs = param.Gdc_convs;
% inv_Lac_convs = param.inv_Lac_convs;
% Zac_convs = param.Zac_convs;
% I_inc_convs = param.I_inc_convs;

%Inf Bus
Z_infbus = param.Z_infbus;
I_inc_infbus = param.I_inc_infbus;
V_infbus = param.V_infbus;


%% Some auxiliary variables that will be useful
num_gens = size(inv_M_gens, 1);
i_gens_size = size(Z_gens, 1);
% num_convs = size(Gdc_convs,1);
% i_convs_size = size(Zac_convs);



%% Define auxiliary variables based on the state and input vectors

i_gens = x(pl.i_gens_init : pl.i_gens_end);
% iac_convs = x(pl.iac_conv_init: pl.i_gens_size + 1 +
i_loads = x(pl.i_loads_init : pl.i_loads_end);
i_lines = x(pl.i_lines_init : pl.i_lines_end);
i_infbus = x(pl.i_infbus_init : pl.i_infbus_end);
v_buses = x(pl.v_buses_init : pl.v_buses_end);
theta_gens = x(pl.theta_gens_init : pl.theta_gens_end);
omega_gens = x(pl.omega_gens_init : pl.omega_gens_end);
% vdc_convs = x(pl.vdc_convs_init : pl.vdc_convs_end);

tau_m_gens = u(pl.tau_m_init : pl.tau_m_end);
i_f_gens = u(pl.i_f_init : pl.i_f_end);
% idc_convs =  u(pl.idc_convs_init : pl.idc_convs_end);
% m_convs = u(pl.m_convs_init : pl.m_convs_end);


%% Compute the derivatives using auxiliary functions

diff_i_gens = di_gens_dt(i_gens, v_buses, theta_gens, omega_gens, i_f_gens, Z_gens, I_inc_gens,  Ell_gens); %Eq (4c)

%diff_i_convs = di_convs_dt(v_buses, iac_convs, vdc_convs, Zac_convs, inv_Lac_convs, I_inc_convs);

diff_i_loads = di_loads_dt(v_buses, i_loads, Z_loads, I_inc_loads); %Eq (10)
%diff_i_loads = 0*diff_i_loads; %Eq (10)

diff_i_lines = di_lines_dt(v_buses, i_lines, Z_lines, E_inc); %Eq (2) Curi Paper

diff_i_infbus = di_infbus_dt(v_buses, i_infbus, V_infbus, Z_infbus, I_inc_infbus);

i_in = -I_inc_gens*i_gens - I_inc_loads*i_loads - I_inc_infbus*i_infbus; %Port variables w/o converter
%i_in = -I_inc_gens*i_gens  - I_inc_infbus*i_infbus;
%%% i_in = I_inc_gens*i_gens - I_inc_loads*i_loads + I_inc_convs*iac_convs;
diff_v_buses = dv_buses_dt(v_buses, i_lines, Y_buses, E_inc, i_in); %Eq (3) Curi Paper

diff_theta_gens = dtheta_gens_dt(omega_gens, omega0); %Eq (4a) Curi

diff_omega_gens = domega_gens_dt(theta_gens, omega_gens, i_gens, i_f_gens, tau_m_gens, inv_M_gens, D_gens, Ell_gens); %Eq (4b) Curi

% diff_vdc_convs = dvdc_convs_dt(idc_convs, iac_convs, vdc_convs, m_convs,
% Gdc_convs, inv_Cdc_convs); %Eq (7a) Curi


%Stack the system
dxdt = [ 
    diff_i_gens; % diff_i_convs;
    diff_i_loads;
    diff_i_lines;
    diff_i_infbus;
    diff_v_buses;
    diff_theta_gens;
    diff_omega_gens]; %diff_vdc_convs