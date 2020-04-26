clear
clc
close all
addpath(genpath('device_equations'));
%% Load data
case_name = 'debug2bus';
[Mat_lines,Mat_buses] = load_network(case_name);
Mat_loads = load_load_impedance(case_name);
Mat_gens = csvread('cases/debug2bus/gen_data.csv', 1,1);
% Mat_infbus = csvread('cases/debug2bus/infbus_data.csv', 1,1);
Mat_infbus = [];
% Mat_convs = csvread('cases/example_3bus/conv_data.csv', 1,1);


%% -- INITIALIZATION -- %%

lines_size = size(Mat_lines, 1); % number of lines
buses_size = size(Mat_buses, 1); % number of buses
loads_size = size(Mat_loads, 1); % number of loads
gens_size  = size(Mat_gens, 1);  % number of gens
% convs_size = size(Mat_convs, 1); % number of DC converters
infbus_size = size(Mat_infbus, 1); %number of infinite buses

omega0 = 120*pi; %nominal angular frequency
j = [cos(pi/2), -sin(pi/2) 
    sin(pi/2) , cos(pi/2)]; % Rotational matrix of pi/2.

%Initialize Line matrices
L_lines = zeros(2*lines_size, 2*lines_size);
R_lines = zeros(2*lines_size, 2*lines_size);
Z_lines = zeros(2*lines_size, 2*lines_size);

%Initialize Incidence Matrix between lines and buses
E_inc = zeros(2*buses_size, 2*lines_size);

%Initialize Bus matrices
G_buses = zeros(2*buses_size, 2*buses_size);
C_buses = zeros(2*buses_size, 2*buses_size);
Y_buses = zeros(2*buses_size, 2*buses_size);

%Initialize load matrices
L_loads = zeros(2*loads_size, 2*loads_size);
R_loads = zeros(2*loads_size, 2*loads_size);
Z_loads = zeros(2*loads_size, 2*loads_size);

%Initialize Incidence Matrix between loads and buses
I_inc_loads = zeros(2*buses_size, 2*loads_size);

%Initialize generator matrices
M_gens = zeros(gens_size, gens_size);
D_gens = zeros(gens_size, gens_size);
L_gens = zeros(2*gens_size, 2*gens_size);
R_gens = zeros(2*gens_size, 2*gens_size);
Z_gens = zeros(2*gens_size, 2*gens_size);
Ell_gens = zeros(gens_size, 1);

%Initialize Incidence Matrix between gens and buses
I_inc_gens = zeros(2*buses_size, 2*gens_size);

% %Initialize converter matrices
% Gdc_convs = zeros(convs_size, convs_size);
% Cdc_convs = zeros(convs_size, convs_size);
% Rac_convs = zeros(2*convs_size, 2*convs_size);
% Lac_convs = zeros(2*convs_size, 2*convs_size);
% Zac_convs = zeros(2*convs_size, 2*convs_size);
% 
% 
% %Initialize Incidence Matrix between converter and buses
% I_inc_convs = zeros(2*buses_size, 2*convs_size);

%Initialize infinite bus data
R_infbus = zeros(2*infbus_size,2*infbus_size);
L_infbus = zeros(2*infbus_size,2*infbus_size);
Z_infbus = zeros(2*infbus_size,2*infbus_size);
V_infbus = zeros(2,infbus_size);

%Initialize Incidence Matrix between infinite bus location and buses
I_inc_infbus = zeros(2*buses_size, 2*infbus_size);



%% -- CONSTRUCT MATRICES -- %%

%Construct Line matrices
for i=1:lines_size %For each line
   r_line = Mat_lines(i,1); %resistance of line i
   l_line = Mat_lines(i,2); %inductance of line i   
   R_lines(2*i-1:2*i, 2*i-1:2*i) = r_line*eye(2); %Resistance Matrix (dq) of line i
   L_lines(2*i-1:2*i, 2*i-1:2*i) = l_line*eye(2); %Inductance Matrix (dq) of line i
   Z_lines(2*i-1:2*i, 2*i-1:2*i) = R_lines(2*i-1:2*i, 2*i-1:2*i) ...
       + j*omega0*L_lines(2*i-1:2*i, 2*i-1:2*i); %Impedance matrix (dq) of line i  
end
inv_L_lines = pinv(L_lines); %Compute pseudo-inverse of L. Pseudo to account for lines with no inductance.

%Construct Incidence Matrix
for i=1:lines_size
    s_bus = Mat_lines(i,3); % sending bus of line i
    r_bus = Mat_lines(i,4); % receiving bus of line i
    E_inc(2*s_bus-1, 2*i-1) = 1; % sending component of d axis
    E_inc(2*r_bus-1, 2*i-1) = -1; % receiving component of d axis
    E_inc(2*s_bus, 2*i) = 1; % sending component of q axis
    E_inc(2*r_bus, 2*i) = -1; % receiving component of q axis
end

%Construct Bus matrices
for i=1:buses_size
    g_bus = Mat_buses(i,1); % conductance of bus i
    c_bus = Mat_buses(i,2); % capacitance of bus i
    G_buses(2*i-1:2*i, 2*i-1:2*i) = g_bus*eye(2); %Conductance Matrix (dq) of bus i
    C_buses(2*i-1:2*i, 2*i-1:2*i) = c_bus*eye(2); %Capacitance Matrix (dq) of bus i
    Y_buses(2*i-1:2*i, 2*i-1:2*i) =  G_buses(2*i-1:2*i, 2*i-1:2*i) ...
        + j*omega0*C_buses(2*i-1:2*i, 2*i-1:2*i); %Admittance Matrix (dq) of bus i
end
inv_C_buses = pinv(C_buses); %Compute inverse of C

% Construct load matrices
for i=1:loads_size %For each load
    bus_number = Mat_loads(i,1);
    r_load = Mat_loads(i,2); %resistance of load i
    l_load = Mat_loads(i,3); %inductance of load i   
    R_loads(2*i-1:2*i, 2*i-1:2*i) = r_load*eye(2); %Resistance Matrix (dq) of load i
    L_loads(2*i-1:2*i, 2*i-1:2*i) = l_load*eye(2); %Inductance Matrix (dq) of load i
    Z_loads(2*i-1:2*i, 2*i-1:2*i) = R_loads(2*i-1:2*i, 2*i-1:2*i) ...
        + j*omega0*L_loads(2*i-1:2*i, 2*i-1:2*i); %Impedance matrix (dq) of load i
    I_inc_loads(2*bus_number-1:2*bus_number, 2*i-1:2*i) = eye(2); % Incidence of load i connected to bus_number
end
inv_L_loads = pinv(L_loads); %Compute inverse of L

%Construct Gen Matrices
for i=1:gens_size %For each generator
    bus_number = Mat_gens(i,1); %bus location of generator i
    r_gen = Mat_gens(i,2); %series resistance of gen i
    l_gen = Mat_gens(i,3); %series inductance of gen i
    ell_gen = Mat_gens(i,4); %mutual inductance between rotor and stator of gen i
    m_gen = Mat_gens(i,5); %inertia constant of gen i
    d_gen = Mat_gens(i,6); %damping constant of gen i
    
    Ell_gens(i) = ell_gen; %Mutual inductance of generator i
    M_gens(i,i) = m_gen; %Inertia constant of generator i
    D_gens(i,i) = d_gen; %Damping constant of generator i
    
    R_gens(2*i-1:2*i, 2*i-1:2*i) = r_gen*eye(2); %Resistance Matrix (dq) of gen i
    L_gens(2*i-1:2*i, 2*i-1:2*i) = l_gen*eye(2); %Inductance Matrix (dq) of gen i
    Z_gens(2*i-1:2*i, 2*i-1:2*i) = R_gens(2*i-1:2*i, 2*i-1:2*i) ...
        + j*omega0*L_gens(2*i-1:2*i, 2*i-1:2*i); %Impedance matrix (dq) of gen i
    
    I_inc_gens(2*bus_number-1:2*bus_number, 2*i-1:2*i) = eye(2); % Incidence of gen i connected to bus_number
end
inv_L_gens = pinv(L_gens); %Compute inverse of L
inv_M_gens = pinv(M_gens); %Compute inverse of M    

% %Construct Converter Matrices
% for i=1:convs_size %For each converter
%    bus_number = Mat_convs(i,1); %bus location of converter i
%    rac_conv = Mat_convs(i,2); %series resistance of AC output filter of converter i 
%    lac_conv = Mat_convs(i,3); %series inductance of AC output filter of converter i
%    gdc_conv = Mat_convs(i,4); %parallel conductance of DC current input source of converter i
%    cdc_conv = Mat_convs(i,5); %parallel capacitance of DC current input source of converter i
%    
%    Gdc_convs(i,i) = gdc_conv; %Conductance of DC side of converter i
%    Cdc_convs(i,i) = cdc_conv; %Capacitance of DC side of converter i
%    
%    Rac_convs(2*i-1:2*i, 2*i-1:2*i) = rac_conv*eye(2); %Resistance Matrix (dq) of output filter of converter i
%    Lac_convs(2*i-1:2*i, 2*i-1:2*i) = lac_conv*eye(2); %Inductance Matrix (dq) of output filter of converter i
%    Zac_convs(2*i-1:2*i, 2*i-1:2*i) = Rac_convs(2*i-1:2*i, 2*i-1:2*i) ...
%         + j*omega0*Lac_convs(2*i-1:2*i, 2*i-1:2*i); %Impedance matrix (dq) of output filter of converter i
%     
%     
%    I_inc_convs(2*bus_number-1:2*bus_number, 2*i-1:2*i) = eye(2); % Incidence of converter i connected to bus_number 
% end
% inv_Cdc_convs = pinv(Cdc_convs); %Compute inverse of Cdc
% inv_Lac_convs = pinv(Lac_convs); %Compute inverse of Lac


%Construct Infinite Bus data

for i=1:infbus_size
    bus_number = Mat_infbus(i,1);
    r_infbus = Mat_infbus(i,2);
    l_infbus = Mat_infbus(i,3);
    v_d_ref = Mat_infbus(i,4);
    v_q_ref = Mat_infbus(i,5);
    
    R_infbus(2*i-1:2*i, 2*i-1:2*i) = r_infbus*eye(2); %Resistance Matrix (dq) of infbus i
    L_infbus(2*i-1:2*i, 2*i-1:2*i) = l_infbus*eye(2); %Inductance Matrix (dq) of infbus i
    Z_infbus(2*i-1:2*i, 2*i-1:2*i) = R_infbus(2*i-1:2*i, 2*i-1:2*i) ...
        + j*omega0*L_infbus(2*i-1:2*i, 2*i-1:2*i); %Impedance matrix (dq) of infbus i
    
    
    I_inc_infbus(2*bus_number-1:2*bus_number, 2*i-1:2*i) = eye(2); % Incidence of infbus i connected to bus_number
    
    V_infbus(1, i) = v_d_ref; %Voltage value of the infinite bus in d component
    V_infbus(2, i) = v_q_ref; %Voltage value of the infinite bus in q component
    
end


%% -- Define a parameter struct to handle all the data -- %%

% Z_infbus = Z_loads;
%Base data
param.omega0 = omega0;
param.j = j;

%Lines
param.R_lines = R_lines;
param.L_lines = L_lines;
param.Z_lines = Z_lines;
param.inv_L_lines = inv_L_lines;
param.E_inc = E_inc;

%Buses
param.G_buses = G_buses;
param.C_buses = C_buses;
param.Y_buses = Y_buses;
param.inv_C_buses = inv_C_buses;

%Loads
param.R_loads = R_loads;
param.L_loads = L_loads;
param.Z_loads = Z_loads;
param.inv_L_loads = inv_L_loads;
param.I_inc_loads = I_inc_loads;

%Generators
param.M_gens = M_gens;
param.D_gens = D_gens;
param.L_gens = L_gens;
param.inv_L_gens = inv_L_gens;
param.inv_M_gens = inv_M_gens;
param.R_gens = R_gens;
param.Z_gens = Z_gens;
param.Ell_gens = Ell_gens;
param.I_inc_gens = I_inc_gens;

% %Converters
% param.Gdc_convs = Gdc_convs;
% param.Cdc_convs = Cdc_convs;
% param.inv_Cdc_convs = inv_Cdc_convs;
% param.Rac_convs = Rac_convs;
% param.Lac_convs = Lac_convs;
% param.inv_Lac_convs = inv_Lac_convs;
% param.Zac_convs = Zac_convs;
% para.I_inc_convs = I_inc_convs;


%Infinite Buses
param.R_infbus = R_infbus;
param.L_infbus = L_infbus;
param.Z_infbus = Z_infbus;
param.I_inc_infbus = I_inc_infbus;
param.V_infbus = V_infbus;


%% Size of state and input vectors

convs_size = 0;

num_variables = 2*gens_size + 2*convs_size + 2*loads_size + 2*lines_size + 2*infbus_size + 2*buses_size ... %AC variables [i_g,i_c, i_l, i_t, i_inf, v]
    + gens_size + gens_size + convs_size ; %DC variables [theta_g, omega_g, v_dc] %Total variables

num_inputs = gens_size + gens_size + convs_size + 2*convs_size; % Inputs [tau_m, i_f, i_dc, m]

param.num_states = num_variables;

%% Split size of state vector

%AC states
i_gens_size = size(Z_gens,1); % number of current of gens variables (2*gens)
% iac_convs_size = size(Zac_convs,1) % number of current of conv vars (2*convs)
iac_conv_size = 0;
i_loads_size = size(Z_loads,1); % number of current of loads variables (2*loads)
i_lines_size = size(Z_lines,1); %obtain number of current of lines variables (2*lines)
i_infbus_size = size(Z_infbus, 1); %obtain number of current of infbus variables (2*infbus)
v_buses_size = size(Y_buses,1); %obtain number of voltage of buses variables (2*buses)

%DC states
theta_gens_size = size(inv_M_gens,1); %number of angle of gens variables (gens)
omega_gens_size = size(inv_M_gens,1); %number of freq of gens variables (gens)
% vdc_convs_size = size(Gdc_convs,1); %number of vdc of convs variables (convs)
vdc_convs_size = 0;
iac_convs_size = 0;

tau_m_size = theta_gens_size; %number of inputs of tau_m
i_f_size = theta_gens_size; %number of inputs of i_f
% idc_convs_size = vdc_convs_size; %number of inputs of i_dc
% m_convs_size = 2*vdc_convs_size; %number of inputs of modulation signal m

%% Split the state vector and input vector

% -- Obtain the limits of the state vector -- %
% AC variables
param_limits.i_gens_init = 1;
param_limits.i_gens_end = param_limits.i_gens_init + i_gens_size - 1;
% param_limits.iac_convs_init = param_limits.i_gens_end + 1;
% param_limits.iac_convs_end = param_limits.iac_conv_init + iac_conv_size -1;
param_limits.iac_convs_end = param_limits.i_gens_end; % no converters case
param_limits.i_loads_init = param_limits.iac_convs_end + 1;
param_limits.i_loads_end = param_limits.i_loads_init + i_loads_size -1;
param_limits.i_lines_init = param_limits.i_loads_end + 1;
param_limits.i_lines_end = param_limits.i_lines_init + i_lines_size -1;
param_limits.i_infbus_init = param_limits.i_lines_end + 1;
param_limits.i_infbus_end = param_limits.i_infbus_init + i_infbus_size -1;
param_limits.v_buses_init = param_limits.i_infbus_end+1;
param_limits.v_buses_end = param_limits.v_buses_init + v_buses_size -1;

% DC variables
param_limits.theta_gens_init = param_limits.v_buses_end + 1;
param_limits.theta_gens_end = param_limits.theta_gens_init + theta_gens_size -1;
param_limits.omega_gens_init = param_limits.theta_gens_end + 1;
param_limits.omega_gens_end = param_limits.omega_gens_init + omega_gens_size -1;
% param_limits.vdc_convs_init = param_limits.omega_gens_end + 1;
% param_limits.vdc_convs_end = param_limits.vdc_convs_init + vdc_convs_size -1;


% -- Obtain the limits of the input vector -- %
param_limits.tau_m_init = 1;
param_limits.tau_m_end = param_limits.tau_m_init + tau_m_size - 1;
param_limits.i_f_init = param_limits.tau_m_end + 1;
param_limits.i_f_end = param_limits.i_f_init + i_f_size -1;
% param_limits.idc_convs_init = param_limits.i_f_end + 1;
% param_limits.idc_convs_end = param_limits.idc_convs_init + idc_convs_size -1;
% param_limits.m_convs_init = param_limits.idc_convs_end + 1;
% param_limits.m_convs_end = param_limits.m_convs_init + m_convs_size -1;

%% Params for closed-loop control

% Turbine
param_cntr.k_droop_p = 20*ones(gens_size,1);
param_cntr.k_droop_i = 2*ones(gens_size,1);
%param_cntr.k_droop_i = zeros(gens_size,1); %Set integral gains to zero to
%only do droop

param_limits_cntr.x_turb_init = 1;
param_limits_cntr.x_turb_end = param_limits_cntr.x_turb_init + gens_size - 1;

% AVR
param_cntr.k_avr = 1*ones(gens_size,1);
param_cntr.v_ref_gen = 1*ones(gens_size,1);

param_limits_cntr.x_avr_init = param_limits_cntr.x_turb_init + 1;
param_limits_cntr.x_avr_end = param_limits_cntr.x_avr_init + gens_size - 1;


%% Solve differential equation
close all
tspan = [0,60];
%x0 = 0.01*ones(num_variables, 1); %initial condition
x0 = [ -1; 0; %i_gen
    1; 0; %i_load
    1; 0; %i_line
    %0; 0; %i_infbus
    %1; 0; 1; 0; %v_buses
    1; 0; 1; 0; %v_buses
    -pi/2;  %theta_gen
    1]; %omega_gen

% Initial states for control states
x0_cntr = [
    1; % tau_m
    1; % i_f
];

Mass_Matrix = eye(num_variables);
for i=1:10
    Mass_Matrix(i,i) = 0;
end


%% Obtain initial conditions
% Get the 
ind_ac = abs(diag(Mass_Matrix)) <= 1e-4;
x_ac_init = find_ac(x0,Mass_Matrix,[1;1],param,param_limits);
x0(ind_ac) = x_ac_init;

%% Solve differential equation system. You can pass parameters to the
%function using this technique
%[t,x] = ode15s(@(t,x)ode_full_system_modular(t,x,u,param, param_limits), tspan, x_init, options);
%[t,x] = ode23t(@(t,x)ode_full_system_modular(t,x,u,param, param_limits), tspan, x0);

% Add components to Mass_Matrix for controller states
Mass_Matrix = blkdiag(Mass_Matrix,eye(length(x0_cntr)));
options = odeset('Mass', Mass_Matrix);

[t,x] = ode15s(@(t,x)ode_full_system_closed_loop(t,x,param,param_cntr,param_limits,param_limits_cntr), tspan, [x0;x0_cntr], options);


%%
v1d = x(:,7);
v1q = x(:,8);
v2d = x(:,9);
v2q = x(:,10);
i2d = x(:,3);
i2q = x(:,4);
i1d = x(:,1);
i1q = x(:,2);

p2 = v2d.*i2d+v2q.*i2q;
q2 = v2q.*i2d-v2d.*i2q;
p1 = v1d.*i1d+v1q.*i1q;
q1 = v1q.*i1d-v1d.*i1q;

%%
figure('units','normalized','outerposition',[0 0 0.8 1])

subplot(4,2,1)
plot(t,x(:, 1:2))
legend('i_{g,d}', 'i_{g,q}')
title('Generator currents i_g')

subplot(4,2,2)
plot(t,x(:, 7:10))
legend('v_{1,d}', 'v_{1,q}','v_{2,d}', 'v_{2,q}')
title('Voltages')

subplot(4,2,3)
plot(t,x(:, 11) + pi/2)
legend('\theta')
title('Generator angle')
ylabel('Radians')

subplot(4,2,4)
plot(t,x(:, 12))
legend('\omega')
title('Generator rotor velocity')

subplot(4,2,5)
plot(t,vecnorm([v1d v1q],2,2),t,vecnorm([v2d v2q],2,2))
title('Voltage Magnitude')
legend('Bus 1','Bus 2')

subplot(4,2,6)
plot(t,[-p1 ,p2])
title('Real Power');
legend('Bus 1 Injected','Bus 2 Consumed')

subplot(4,2,7)
plot(t,x(:,14))
legend('i_f')
title('Field current');

subplot(4,2,8)
plot(t,x(:,13))
legend('\tau_m')
title('Mechanical torque');

saveas(gcf,'figures\main_2bus_closed_loop_AVR_turb.png')