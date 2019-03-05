clear
clc
%% Load data

file_buses = 'bus_data.csv'; %load bus data
file_lines = 'line_data.csv'; %load line data

M_lines = csvread(file_lines, 1,1); %Read line data as Matrix. 1,1 means that it skips the first row and first column
M_buses = csvread(file_buses, 1,2); %Read bus data as Matrix. 1,2 means that skips first row and the two first columns

%% Construct parameters

%Initialization
lines_size = size(M_lines, 1); % number of lines
buses_size = size(M_buses, 1); % number of buses
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
inv_L_lines = inv(L_lines); %Compute inverse of L

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
inv_C_buses = inv(C_buses); %Compute inverse of C


%% Solve differential equation
num_variables = 2*buses_size + 2*lines_size; %number of variables

tspan = [0,0.05];
y0 = zeros(num_variables, 1); %initial condition
Mass_Matrix = eye(num_variables);
options = odeset('Mass', Mass_Matrix);

%Solve differential equation system. You can pass parameters to the
%function using this technique
[t,y] = ode15s(@(t,y)ode_full_system_modular(t,y,inv_L_lines, Z_lines, ...
    E_inc, inv_C_buses, Y_buses), tspan, y0, options);


plot(t,y)
