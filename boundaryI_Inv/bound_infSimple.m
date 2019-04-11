function inverter_dxdt=bound_infSimple(x,params);

% Internal states of each block
% Note: everything passed into a sub function must be a param or a state!
Vg=x(1);
Iqterm=x(2);
Ipterm=x(3);
I1=x(4);
I2=x(5);


inverter_dxdt=[
% DAEs

    infBusNwk(Ipterm,Iqterm,Vg,I1,I2,params);
    ];
