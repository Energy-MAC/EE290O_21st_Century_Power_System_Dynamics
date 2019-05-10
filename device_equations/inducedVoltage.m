function v_ind = inducedVoltage(theta_g, omega_g, i_f, l_m)
%This function represents voltage induced in the stator as described in Equation (6) in Curi Paper

v_ind = l_m * i_f* omega_g * [ cos(pi/2) -sin(pi/2); sin(pi/2) cos(pi/2)]*[cos(theta_g); sin(theta_g)];
end