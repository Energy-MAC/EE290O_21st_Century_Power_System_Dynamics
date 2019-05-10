function digdt = di_gens_dt(i_gens, v_buses, theta_gens, omega_gens,  i_f_gens, Z_gens, I_inc_gens, Ell_gens)
%This function represents generator dynamics based off Equation (4c) in Curi Paper

num_gens = length(theta_gens);
v_ind_gens = zeros(2*num_gens,1);
for i=1:num_gens
    v_ind_gens(2*i-1:2*i) = inducedVoltage(theta_gens(i), omega_gens(i), i_f_gens(i), Ell_gens(i));    
end

digdt = (-Z_gens * i_gens + I_inc_gens'*v_buses - v_ind_gens);
end