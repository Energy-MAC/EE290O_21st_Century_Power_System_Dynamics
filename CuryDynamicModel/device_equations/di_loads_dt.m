function didt = di_loads_dt(v_buses, i_loads,  Z_loads, I_inc_loads)
%This function returns the derivative of the current to loads
%Equation (10) in Curi Paper

didt = (-Z_loads*i_loads + I_inc_loads'*v_buses);
%didt = -i_loads;
end