function domegagdt = generatorDynamics_freq(invM, D,omega_g, tao_m, tao_e)
%This function represents generator dynamics based off Equation (4b) in Curi Paper

domegagdt = invM*(-D*omega_g + tao_m - tao_k);
end