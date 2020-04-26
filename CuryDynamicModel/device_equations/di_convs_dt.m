function dic_dt = di_convs_dt(v_buses, ic, th, vdc, mu, Zac_converters, inv_Lac_converters, I_inc_convs)
%{
Differential equations for the current on the ac side of the converters

states:
    v_buses = nodal dq voltages for converter nodes only stacked 2by2by2.., size = nconverters*2
    ic = vector of ac converter currents in dq ref frame stacked 2by2by2.., size = nconverters*2
inputs:
    vdc = vector of dc voltages, size = nconverters
    mu = vector of inputs used to determine m using virtual osc, size = nconverters
    th = theta of converter's virtual oscillator angle, size = nconverters*2
%}
j = [0 -1;1 0];

nconverters = length(vdc);
vsw = zeros(2*nconverters,1);
for i = 1:nconverters
    m = mu(i)*j*[cos(th(i));sin(th(i))];
    vsw(2*i-1:2*i) = vdc(i)*m/2;
end

%dic_dt = inv_Lac_converters*(-Zac_converters*ic + I_inc_convs'*v_buses - vsw);
dic_dt = (-Zac_converters*ic + I_inc_convs'*v_buses - vsw);

end