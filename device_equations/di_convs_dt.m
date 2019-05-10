function dic_dt = di_convs_dt(v_buses, ic, vdc, m, Zac_converters, inv_Lac_converters, I_inc_convs)
%{
Differential equations for the current on the ac side of the converters

states:
    v_convertersonly = nodal dq voltages for converter nodes only stacked 2by2by2.., size = nconverters*2
    ic = vector of ac converter currents in dq ref frame stacked 2by2by2.., size = nconverters*2
inputs:
    vdc = vector of dc voltages, size = nconverters
    m = vector of inputs stacked 2by2by2.., size = nconverters*2
%}

nconverters = length(vdc);
vsw = zeros(2*nconverters,1);
for i = 1:nconverters
    vsw(2*i-1:2*i) = vdc(i)*m(2*i-1:2*i)/2; 
end

dic_dt = inv_Lac_converters*(-Zac_converters*ic + I_inc_convs'*v_buses - vsw);

end