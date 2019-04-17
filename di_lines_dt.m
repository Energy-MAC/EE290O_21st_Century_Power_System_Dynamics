function didt = di_lines_dt(v_buses, i_lines, inv_L_lines, Z_lines, E_inc)
%This function returns the derivative of the current over lines
%Equation (2) in Curi Paper

%didt = inv_L_lines*(-Z_lines*i_lines + E_inc'*v_buses);
didt = (-Z_lines*i_lines + E_inc'*v_buses);
end