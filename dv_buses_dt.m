function dvbdt = dv_buses_dt(v_buses, i_lines, inv_C_buses, Y_buses, E_inc, i_in)
%This function returns the derivative of the voltage in buses
%Equation (3) in Curi Paper

dvbdt = -inv_C_buses*Y_buses*v_buses + inv_C_buses*E_inc*i_lines + i_in;
end

