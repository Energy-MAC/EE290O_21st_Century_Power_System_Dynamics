clear
clc
%% Load data
case_name = 'example_3bus';
[M_lines,M_buses] = load_network(case_name);
M_loads = load_load_impedance(case_name);

%% Construct parameters

%Initialization
lines_size = size(M_lines, 1); % number of lines
buses_size = size(M_buses, 1); % number of buses
loads_size = size(M_loads, 1); % number of loads
omega0 = 120*pi; %nominal angular frequency
j = [cos(pi/2), -sin(pi/2) 
    sin(pi/2) , cos(pi/2)]; % Rotational matrix of pi/2.

%Initialize Line matrices
L_lines = zeros(2*lines_size, 2*lines_size);
R_lines = zeros(2*lines_size, 2*lines_size);
Z_lines = zeros(2*lines_size, 2*lines_size);


%Construct Line matrices
for i=1:lines_size %For each line
   r_line = M_lines(i,1); %resistance of line i
   l_line = M_lines(i,2); %inductance of line i   
   R_lines(2*i-1:2*i, 2*i-1:2*i) = r_line*eye(2); %Resistance Matrix (dq) of line i
   L_lines(2*i-1:2*i, 2*i-1:2*i) = l_line*eye(2); %Inductance Matrix (dq) of line i
   Z_lines(2*i-1:2*i, 2*i-1:2*i) = R_lines(2*i-1:2*i, 2*i-1:2*i) ...
       + j*omega0*L_lines(2*i-1:2*i, 2*i-1:2*i); %Impedance matrix (dq) of line i  
end
inv_L_lines = pinv(L_lines); %Compute pseudo-inverse of L. Pseudo to account for lines with no inductance.

%Initialize Incidence Matrix
E_inc = zeros(2*buses_size, 2*lines_size);

%Construct Incidence Matrix
for i=1:lines_size
    s_bus = M_lines(i,3); % sending bus of line i
    r_bus = M_lines(i,4); % receiving bus of line i
    E_inc(2*s_bus-1, 2*i-1) = 1; % sending component of d axis
    E_inc(2*r_bus-1, 2*i-1) = -1; % receiving component of d axis
    E_inc(2*s_bus, 2*i) = 1; % sending component of q axis
    E_inc(2*r_bus, 2*i) = -1; % receiving component of q axis
end

%Initialize Bus matrices
G_buses = zeros(2*buses_size, 2*buses_size);
C_buses = zeros(2*buses_size, 2*buses_size);
Y_buses = zeros(2*buses_size, 2*buses_size);

%Construct Bus matrices
for i=1:buses_size
    g_bus = M_buses(i,1); % conductance of bus i
    c_bus = M_buses(i,2); % capacitance of bus i
    G_buses(2*i-1:2*i, 2*i-1:2*i) = g_bus*eye(2); %Conductance Matrix (dq) of bus i
    C_buses(2*i-1:2*i, 2*i-1:2*i) = c_bus*eye(2); %Capacitance Matrix (dq) of bus i
    Y_buses(2*i-1:2*i, 2*i-1:2*i) =  G_buses(2*i-1:2*i, 2*i-1:2*i) ...
        + j*omega0*C_buses(2*i-1:2*i, 2*i-1:2*i); %Admittance Matrix (dq) of bus i
end
inv_C_buses = pinv(C_buses); %Compute inverse of C

%Initialize load matrices
L_loads = zeros(2*loads_size, 2*loads_size);
R_loads = zeros(2*loads_size, 2*loads_size);
Z_loads = zeros(2*loads_size, 2*loads_size);
I_inc_loads = zeros(2*buses_size, 2*loads_size);

% Construct load matrices
for i=1:loads_size %For each load
    bus_number = M_loads(i,1);
    r_load = M_loads(i,2); %resistance of load i
    l_load = M_loads(i,3); %inductance of load i   
    R_loads(2*i-1:2*i, 2*i-1:2*i) = r_load*eye(2); %Resistance Matrix (dq) of load i
    L_loads(2*i-1:2*i, 2*i-1:2*i) = l_load*eye(2); %Inductance Matrix (dq) of load i
    Z_loads(2*i-1:2*i, 2*i-1:2*i) = R_loads(2*i-1:2*i, 2*i-1:2*i) ...
        + j*omega0*L_loads(2*i-1:2*i, 2*i-1:2*i); %Impedance matrix (dq) of load i
    I_inc_loads(2*bus_number-1:2*bus_number, 2*i-1:2*i) = eye(2); % Incidence of load i connected to bus_number
end
inv_L_loads = pinv(L_loads); %Compute inverse of L

%% Define a parameter struct to handle all the data

param.R_lines = R_lines;
param.L_lines = L_lines;
param.Z_lines = Z_lines;
param.inv_L_lines = inv_L_lines;
param.E_inc = E_inc;
param.G_buses = G_buses;
param.C_buses = C_buses;
param.Y_buses = Y_buses;
param.inv_C_buses = inv_C_buses;

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
