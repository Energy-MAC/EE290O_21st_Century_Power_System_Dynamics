function digdt = generatorDynamics_fieldcurrent(invL_g, Z_g, I_g, v_ind, i_g, v)
%This function represents generator dynamics based off Equation (4c) in Curi Paper

digdt = invL_g *(-Z_g * i_g + kron(I_g,eye(2))' *  v - v_ind) ;
end