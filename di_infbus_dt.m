function didt = di_infbus_dt(v_buses, i_infbus, V_infbus, Z_infbus, I_inc_infbus)
%This function returns the derivative of the current to loads
%Equation (10) in Curi Paper

num_infbus = size(V_infbus,2);
v_ref = zeros(2*num_infbus,1);

for i=1:num_infbus
    v_ref(2*i-1) = V_infbus(1,i);
    v_ref(2*i)   = V_infbus(2,i);
end

didt = (-Z_infbus*i_infbus + I_inc_infbus'*v_buses - v_ref);