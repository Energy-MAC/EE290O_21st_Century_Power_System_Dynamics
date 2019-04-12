function  dvdc_dt = dvdc_convs_dt(idc, ic, vdc, m, Gdc_converters, inv_Cdc_converters)
%{
Differential equations for the voltage on the dc side of the converters

states:
    idc = dc injection current, size = nconverters
    vdc = vector of dc voltages, size = nconverters
inputs:
    ic = vector of ac converter currents, size = nconverters*2
    m = vector of inputs, size + nconverters*2
%}

nconverters = length(vdc);
isw = zeros(nconverters,1);
for i = 1:nconverters
    isw(i) = -ic(2*i-1:2*i)'*m(2*i-1:2*i)/2; 
end

dvdc_dt = inv_Cdc_converters*(-Gdc_converters*vdc + idc - isw);

end