function dvbdt = dv_buses_dt(v_buses, i_lines,  Y_buses, E_inc, i_in)
%This function returns the derivative of the voltage in buses
%Equation (3) in Curi Paper

dvbdt = (-Y_buses*v_buses + E_inc*i_lines + i_in);
end

