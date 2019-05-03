function inverter_dxdt=bound_infSimple(t,x,params)

% Internal states of each block
% Note: everything passed into a sub function must be a param or a state!
Vterm=x(1);
Vterm_theta=x(2);
Ipterm=x(3);
Iqterm=x(4);
Pline=x(5);
Qline=x(6);

inverter_dxdt=[
% DAEs
    0; % x(1)dot=0 --> constant
    0;
    0;
    0;
    infBusNwk(Ipterm,Iqterm,Vterm,Vterm_theta,Pline,Qline,params);
    ];
end