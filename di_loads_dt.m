function didt = di_loads_dt(v_buses, i_loads, inv_L_loads, Z_loads, I_inc_loads)
%This function returns the derivative of the current to loads
%Equation (10) in Curi Paper

%didt = inv_L_loads*(-Z_loads*i_loads + I_inc_loads'*v_buses - [0;1]);
didt = (-Z_loads*i_loads + I_inc_loads'*v_buses - [0;1]);
end