function digdt = di_gens_dt(i_gens, v_buses, invL_gens, Z_gens, I_inc_gens, v_ind_gens)
%This function represents generator dynamics based off Equation (4c) in Curi Paper

digdt = invL_gens*(-Z_gens * i_gens + I_inc_gens'*v_buses - v_ind_gens);
end