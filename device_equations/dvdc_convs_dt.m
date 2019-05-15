function  dvdc_dt = dvdc_convs_dt(idc, ic, th, vdc, mu, Gdc_converters, inv_Cdc_converters, vdcref)
%{
Differential equations for the voltage on the dc side of the converters

states:
    idc = dc injection current, size = nconverters
    vdc = vector of dc voltages, size = nconverters
inputs:
    ic = vector of ac converter currents (positive into conv), size = nconverters*2
    mu = vector of inputs used to determine m using virtual osc, size = nconverters
    th = theta of converter's virtual oscillator angle, size = nconverters*2
%}
j = [0 -1;1 0];

nconverters = length(vdc);
isw = zeros(nconverters,1);
for i = 1:nconverters
    m = mu(i)*j*[cos(th(i));sin(th(i))];
    isw(i) = -ic(2*i-1:2*i)'*m/2; 
end

dvdc_dt = inv_Cdc_converters*(-Gdc_converters*vdc + idc - isw);
%dvdc_dt = inv_Cdc_converters*(-Gdc_converters*vdc + (idc + Gdc_converters*vdcref) - isw);
%dvdc_dt = inv_Cdc_converters*(-Gdc_converters*vdc + idc - 0.01*(vdc-vdcref) - isw);

end