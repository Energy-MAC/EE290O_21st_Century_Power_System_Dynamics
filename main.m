clear
clc
%% Load data
case_name = 'example_3bus';
[Mat_lines,Mat_buses] = load_network(case_name);
Mat_loads = load_load_impedance(case_name);
Mat_gens = csvread('cases/example_3bus/gen_data.csv', 1,1);


%% -- INITIALIZATION -- %%

lines_size = size(Mat_lines, 1); % number of lines
buses_size = size(Mat_buses, 1); % number of buses
loads_size = size(Mat_loads, 1); % number of loads
gens_size  = size(Mat_gens, 1);  % number of gens
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
    ell_gen = Mat_gen(i,4); %mutual inductance between rotor and stator of gen i
    m_gen = Mat_gen(i,5); %inertia constant of gen i
    d_gen = Mat_gen(i,6); %damping constant of gen i
    
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



%% Define a parameter struct to handle all the data

param.omega0 = omega0;
param.j = j;

param.R_lines = R_lines;
param.L_lines = L_lines;
param.Z_lines = Z_lines;
param.inv_L_lines = inv_L_lines;
param.E_inc = E_inc;

param.G_buses = G_buses;
param.C_buses = C_buses;
param.Y_buses = Y_buses;
param.inv_C_buses = inv_C_buses;

param.M_gens = M_gens;
param.D_gens = D_gens;
param.L_gens = L_gens;
param.inv_L_gens = inv_L_gens;
param.inv_M_gens = inv_M_gens;
param.R_gens = R_gens;
param.Z_gens = Z_gens;
param.Ell_gens = Ell_gens;

param.R_loads = R_loads;
param.L_loads = L_loads;
param.Z_loads = Z_loads;
param.inv_L_loads = inv_L_loads;
param.I_inc_loads = I_inc_loads;



%% Solve differential equation
num_variables = 2*buses_size + 2*lines_size; %number of variables

tspan = [0,0.2];
x0 = zeros(num_variables, 1); %initial condition
Mass_Matrix = eye(num_variables);
options = odeset('Mass', Mass_Matrix);

%Solve differential equation system. You can pass parameters to the
%function using this technique
[t,x] = ode15s(@(t,x)ode_full_system_modular(t,x,param), tspan, x0, options);


plot(t,x)
