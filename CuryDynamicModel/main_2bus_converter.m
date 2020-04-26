clear
clc
close all
addpath(genpath('device_equations'))

%{
TO DO:
get network workign with all 3
include droop
%}


%% Load data

case_name = 'debug2bus_converters'; %no infbus and no gens
%case_name = 'example_2bus_infbus';
%case_name = 'debug2bus_gen'; %no infbus and no convs
[Mat_lines,Mat_buses] = load_network(case_name);
Mat_loads = load_load_impedance(case_name);
Mat_infbus = load_infbus(case_name);
Mat_convs = load_convs(case_name);
Mat_gens = load_gens(case_name);

tspan = [0 10];

%% Inputs
% if fsolve is free to change the inputs to find an equilibirium point
% (must put in a value for each gen and each conv)
% one or both may be free for a given conv
% should be empty if no gens/convs exist

tau_m_gens_free = logical([]);
i_fs_gens_free = logical([]);
i_dc_convs_free = logical([true]);   
mu_convs_free = logical([true]);

%% Initial guesses of state vars and inputs
%fsolve finds an equilibrium point, but starts at these initial guesses
%solution is sensitive to initial guess
%currents are defined as positive out of the network

initialGuess_i_gens = -1;    
initialGuess_i_convs = -1;
initialGuess_i_loads = 1;
initialGuess_i_lines = 0;
initialGuess_i_infbus = 0;
initialGuess_v_buses = 1;

initialGuess_theta_gens = -pi/2;
initialGuess_omega_gens = 1;
initialGuess_theta_convs = -pi/2;
initialGuess_vdc_convs = 2;

initialGuess_tau_m_gens = 1;
initialGuess_i_f_gens = 1;
initialGuess_i_dc_convs = .05;
initialGuess_mu_convs = 1;

%% -- INITIALIZATION -- %%

lines_size = size(Mat_lines, 1); % number of lines
buses_size = size(Mat_buses, 1); % number of buses
loads_size = size(Mat_loads, 1); % number of loads
gens_size  = size(Mat_gens, 1);  % number of gens
convs_size = size(Mat_convs, 1); % number of converters
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

%Initialize converter matrices
vdcref_convs = zeros(convs_size);
kmc_convs = zeros(convs_size);
Gdc_convs = zeros(convs_size, convs_size);
Cdc_convs = zeros(convs_size, convs_size);
Rac_convs = zeros(2*convs_size, 2*convs_size);
Lac_convs = zeros(2*convs_size, 2*convs_size);
Zac_convs = zeros(2*convs_size, 2*convs_size);
%Initialize Incidence Matrix between converter and buses
I_inc_convs = zeros(2*buses_size, 2*convs_size);

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
%Z_loads = [1 -.05; .05 1];
%L_loads = 0.05*L_loads;
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

%Construct Converter Matrices
for i=1:convs_size %For each converter
   bus_number = Mat_convs(i,1); %bus location of converter i
   rac_conv = Mat_convs(i,2); %series resistance of AC output filter of converter i 
   lac_conv = Mat_convs(i,3); %series inductance of AC output filter of converter i
   gdc_conv = Mat_convs(i,4); %parallel conductance of DC current input source of converter i
   cdc_conv = Mat_convs(i,5); %parallel capacitance of DC current input source of converter i
   vdcref_conv = Mat_convs(i,6);
   kmc_conv = Mat_convs(i,7);
   
   Gdc_convs(i,i) = gdc_conv; %Conductance of DC side of converter i
   Cdc_convs(i,i) = cdc_conv; %Capacitance of DC side of converter i
   
   Rac_convs(2*i-1:2*i, 2*i-1:2*i) = rac_conv*eye(2); %Resistance Matrix (dq) of output filter of converter i
   Lac_convs(2*i-1:2*i, 2*i-1:2*i) = lac_conv*eye(2); %Inductance Matrix (dq) of output filter of converter i
   Zac_convs(2*i-1:2*i, 2*i-1:2*i) = Rac_convs(2*i-1:2*i, 2*i-1:2*i) ...
        + j*omega0*Lac_convs(2*i-1:2*i, 2*i-1:2*i); %Impedance matrix (dq) of output filter of converter i
    
   vdcref_convs(i) = vdcref_conv; %matching control parameter 1
   kmc_convs(i) = kmc_conv; %matching control parameter 2
    
   I_inc_convs(2*bus_number-1:2*bus_number, 2*i-1:2*i) = eye(2); % Incidence of converter i connected to bus_number 
end
inv_Cdc_convs = pinv(Cdc_convs); %Compute inverse of Cdc
inv_Lac_convs = pinv(Lac_convs); %Compute inverse of Lac

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

%Converters
param.Gdc_convs = Gdc_convs;
param.Cdc_convs = Cdc_convs;
param.inv_Cdc_convs = inv_Cdc_convs;
param.Rac_convs = Rac_convs;
param.Lac_convs = Lac_convs;
param.inv_Lac_convs = inv_Lac_convs;
param.Zac_convs = Zac_convs;
param.I_inc_convs = I_inc_convs;
param.kmc_convs = kmc_convs;
param.vdcref_convs = vdcref_convs;

%Infinite Buses
param.R_infbus = R_infbus;
param.L_infbus = L_infbus;
param.Z_infbus = Z_infbus;
param.I_inc_infbus = I_inc_infbus;
param.V_infbus = V_infbus;


%% Size of state and input vectors

num_variables = 2*gens_size + 2*convs_size + 2*loads_size + 2*lines_size + 2*infbus_size + 2*buses_size ... %AC variables [i_g,i_c, i_l, i_t, i_inf, v]
    + gens_size + gens_size + convs_size + convs_size ; %DC variables [theta_g, omega_g, theta_c, v_dc] %Total variables

numAC_variables = 2*gens_size + 2*convs_size + 2*loads_size + 2*lines_size + 2*infbus_size + 2*buses_size;

num_inputs = gens_size + gens_size + convs_size + convs_size; % Inputs [tau_m, i_f, i_dc, mu]

%% Split size of state vector

%AC states
i_gens_size = size(Z_gens,1); % number of current of gens variables (2*gens)
%i_gens_size = 0;
iac_convs_size = size(Zac_convs,1); % number of current of conv vars (2*convs)
i_loads_size = size(Z_loads,1); % number of current of loads variables (2*loads)
i_lines_size = size(Z_lines,1); %obtain number of current of lines variables (2*lines)
i_infbus_size = size(Z_infbus, 1); %obtain number of current of infbus variables (2*infbus)
v_buses_size = size(Y_buses,1); %obtain number of voltage of buses variables (2*buses)

%DC states
theta_gens_size = size(inv_M_gens,1); %number of angle of gens variables (gens)
omega_gens_size = size(inv_M_gens,1); %number of freq of gens variables (gens)
theta_convs_size = size(Gdc_convs,1); %number of virtual osc. angle convs variables (convs)
vdc_convs_size = size(Gdc_convs,1); %number of vdc of convs variables (convs)

tau_m_size = theta_gens_size; %number of inputs of tau_m
i_f_size = theta_gens_size; %number of inputs of i_f
idc_convs_size = vdc_convs_size; %number of inputs of i_dc
mu_convs_size = vdc_convs_size; %number of inputs of modulation signal mu, m = mu*j*r(theta)

%% Split the state vector and input vector

% -- Obtain the limits of the state vector -- %
% AC variables
param_limits.i_gens_init = 1;
param_limits.i_gens_end = param_limits.i_gens_init + i_gens_size - 1; 
param_limits.iac_convs_init = param_limits.i_gens_end + 1;
param_limits.iac_convs_end = param_limits.iac_convs_init + iac_convs_size -1;
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
param_limits.theta_convs_init = param_limits.omega_gens_end + 1;
param_limits.theta_convs_end = param_limits.theta_convs_init + theta_convs_size -1;
param_limits.vdc_convs_init = param_limits.theta_convs_end + 1; 
param_limits.vdc_convs_end = param_limits.vdc_convs_init + vdc_convs_size -1;

% -- Obtain the limits of the input vector -- %
param_limits.tau_m_init = 1;
param_limits.tau_m_end = param_limits.tau_m_init + tau_m_size - 1;
param_limits.i_f_init = param_limits.tau_m_end + 1;
param_limits.i_f_end = param_limits.i_f_init + i_f_size -1; 
param_limits.idc_convs_init = param_limits.i_f_end + 1;
param_limits.idc_convs_end = param_limits.idc_convs_init + idc_convs_size -1;
param_limits.mu_convs_init = param_limits.idc_convs_end + 1;
param_limits.mu_convs_end = param_limits.mu_convs_init + mu_convs_size -1;


%% Solve differential equation for converters

x0 = [ kron(ones(gens_size,1),[initialGuess_i_gens;0]); %i_conv
       kron(ones(convs_size,1),[initialGuess_i_convs;0]); %i_conv
       kron(ones(loads_size,1),[initialGuess_i_loads;0]); %i_load
       kron(ones(lines_size,1),[initialGuess_i_lines;0]); %i_line
       kron(ones(infbus_size,1),[initialGuess_i_infbus;0]); %i_infbus
       kron(ones(buses_size,1),[initialGuess_v_buses;0]); %v_buses
       kron(ones(gens_size,1),[initialGuess_theta_gens]); %theta_gens
       kron(ones(gens_size,1),[initialGuess_omega_gens]); %omega_gens
       kron(ones(convs_size,1),[initialGuess_theta_convs]); %theta_convs
       kron(ones(convs_size,1),[initialGuess_vdc_convs])]; %vdc_convs

u = [kron(ones(gens_size,1),[initialGuess_tau_m_gens]); % tau_m
     kron(ones(gens_size,1),[initialGuess_i_f_gens]); % i_f 
     kron(ones(convs_size,1),[initialGuess_i_dc_convs]); % idc (vdcref is 2)    
     kron(ones(convs_size,1),[initialGuess_mu_convs])]; % mu = 2vacmag/vdc (from p 11 of Jouini)
 
Mass_Matrix = eye(num_variables);
for i=1:numAC_variables %this is specifically for a two node network w an inf bus or const impedance load
    Mass_Matrix(i,i) = 0;
end
options = odeset('Mass', Mass_Matrix);

x_init = x0;


%% Find an appropriate initial condition

%{
% Show that we need free 'u' variables
try
    find_eq(x0,Mass_Matrix,u,param,param_limits);
catch e
    disp('See it does not work to hold all inputs fixed!');
end
%}

u_free = [tau_m_gens_free; i_fs_gens_free; i_dc_convs_free; mu_convs_free];
[x_eq,u(u_free)] = find_eq_u_conv(x0,Mass_Matrix,u,u_free,param,param_limits);

% Set initial conditions to be equilibrium
x_init = x_eq;
u_used = u;

% Perturb frequency
%x_init(12) = x_init(12)+0.01; %Comment out to show that if we start at equilibrium, we stay there


%% Solve differential equation system. You can pass parameters to the
%function using this technique
dev = -0.2;
%dev = 0;
param.Z_loads = [1+dev, -0.05; 0.05, 1+dev];
tspan = [0 6];
%x_init(12) = x_init(12)+0.1;
[t,x] = ode15s(@(t,x)ode_full_system_modular_conv(t,x,u,param, param_limits), tspan, x_init, options);
%[t,x] = ode23t(@(t,x)ode_full_system_modular(t,x,u,param, param_limits), tspan, x0);

%% Plots

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




figure('units','normalized','outerposition',[0 0 1 1])


subplot(3,2,1)
plot(t,x(:, 7:10))
legend('v_{1,d}', 'v_{1,q}','v_{2,d}', 'v_{2,q}')
title('Voltages')

x1mag = (x(:,numAC_variables-3).^2 + x(:,numAC_variables-2).^2).^.5;
x2mag = (x(:,numAC_variables-1).^2 + x(:,numAC_variables).^2).^.5;
subplot(3,2,2)
plot(t,x1mag,t,x2mag)
legend('v_{1mag}','v_{2mag}')
title('Voltage Magnitude')

subplot(3,2,3)
plot(t,[-p1 ,p2])
title('Real Power');
legend('Bus 1 Injected','Bus 2 Consumed')

subplot(3,2,4)
plot(t,[-q1 ,q2])
title('Reactive Power');
legend('Bus 1 Injected','Bus 2 Consumed')

subplot(3,2,5)
plot(t,x(:, 11) + pi/2)
legend('Theta')
title('Converter Virtual Angle')

subplot(3,2,6)
plot(t,x(:, 12))
legend('V_{dc}')
title('Converter DC Voltage')

saveas(gcf,'main_2bus_converterexample_v3.pdf')

%{
figure()
plot(t,x(:, 9:10))
legend('v_{1,d}', 'v_{1,q}')
title('Voltages')

figure()
plot(t,x(:, 11:12))
legend('v_{2,d}', 'v_{2,q}')
title('Voltages')
%}

%{
fig1 = figure(1)
plot(t,x(:, 1:2))
legend('i_{g,d}', 'i_{g,q}')
title('Generator currents i_g')

fig2 = figure(2)
plot(t,x(:, 3:4))
legend('i_{l,d}', 'i_{l,q}')
title('Load currents i_l')

fig3 = figure(3)
plot(t,x(:, 5:6))
legend('i_{t,d}', 'i_{t,q}')
title('Line currents i_t')

fig4 = figure(4)
plot(t,x(:, 7:8))
legend('i_{inf,d}', 'i_{inf,q}')
title('Inf bus currents i_inf')

fig5 = figure(5)
plot(t,x(:, 13) + pi/2)
legend('\theta')
title('Generator angle')

fig6 = figure(6)
plot(t,x(:, 14))
legend('\omega')
title('Generator rotor velocity')
%}

