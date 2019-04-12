function inverter_dxdt=bound_infSimple(x,params);

% Internal states of each block
% Note: everything passed into a sub function must be a param or a state!
Vterm=x(1);
Vterm_theta=x(2);
Iqterm=x(3);
Ipterm=x(4);
Pline=x(5);
Qline=x(6);

inverter_dxdt=[
% DAEs
    infBusNwk(Ipterm,Iqterm,Vterm,Vterm_theta,Pline,Qline,params);
    ];
