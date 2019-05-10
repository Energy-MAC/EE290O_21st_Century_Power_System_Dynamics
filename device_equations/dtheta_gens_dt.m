function dthetagdt = dtheta_gens_dt(omega_g, omega0)
%This function represents generator dynamics based off Equation (4a) in Curi Paper

dthetagdt = omega0*(omega_g - 1);
end