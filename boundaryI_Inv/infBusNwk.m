function f = infBusNwk(Ipterm,Iqterm,Vg,I1,I2,params)
% Iterm=Ipterm+j*Iqterm; % complex, phasor
% Params
Ze=j*(params.Xe)
ZL=params.ZL
Vinf=params.Vinf

f=[
    %0=
    ((Ipterm+j*Iqterm)*Ze*ZL+Vinf*ZL)/(ZL+j*Ze)-Vg
    %0=
    (Vg-Vinf)/Ze-I1;
    %0=
    Vg/ZL-I2;
];
end

