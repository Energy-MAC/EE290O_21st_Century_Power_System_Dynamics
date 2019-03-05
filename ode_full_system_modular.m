function dydt = ode_full_system_modular(t,y, inv_L_lines, Z_lines, E_inc, inv_C_buses, Y_buses)

% this function returns the whole differential equation system of Curi
% paper in a modular fashion


v_buses_size = size(Y_buses,1); %obtain number of voltage of buses variables (2*buses)
i_lines_size = size(Z_lines,1); %obtain number of current of lines variables (2*lines)

%Split the y variable in its parts

v_buses = y(1:v_buses_size); 
i_lines = y(v_buses_size+1:end);


%Some particular case of input current at node 1.
i_in = zeros( size(Y_buses,1), 1);
i_in(1) = 100;

%Compute the derivatives using auxiliary functions
diff_v_buses = dv_buses_dt(v_buses, i_lines, inv_C_buses, Y_buses, E_inc, i_in); %Eq (3) Curi Paper
diff_i_lines = di_lines_dt(v_buses, i_lines, inv_L_lines, Z_lines, E_inc); %Eq (2) Curi Paper

%Stack the system
dydt = [ 
    diff_v_buses;
    diff_i_lines];