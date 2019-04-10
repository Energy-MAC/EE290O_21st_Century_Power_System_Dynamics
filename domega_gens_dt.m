function domegag_dt = domega_gens_dt(omega_g, invM, D, tau_m, tau_e)
%This function represents generator dynamics based off Equation (4b) in Curi Paper

domegag_dt = invM*(-D*omega_g + tau_m - tau_e);
end