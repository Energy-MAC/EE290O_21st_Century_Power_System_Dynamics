function domegag_dt = domega_gens_dt(theta_g, omega_g, i_g, i_f, tau_m, invM, D, l_m)
%This function represents generator dynamics based off Equation (4b) in Curi Paper

num_gens = length(omega_g);
tau_e = zeros(num_gens,1);

for i=1:num_gens
   tau_e(i) = electricalTorque(theta_g(i), i_g(2*i-1:2*i), i_f(i), l_m(i)); 
end
%tau_e
domegag_dt = invM*(-D*(omega_g-1) + tau_m - tau_e)/2;
end