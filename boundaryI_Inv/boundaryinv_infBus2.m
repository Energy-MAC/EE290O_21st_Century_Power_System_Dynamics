% Version removes triple integrator from inverter model compared to
% boundaryinv_infBus
% -----------------------------------------------
% Create simple circuit, inverter, RLC load, gnd
function inverter_dxdt=boundaryinv_infBus(t,x,params,Ts)
% Note: everything passed into a sub function must be a param or a state!
% Note: order of states is exactly alligned with ordering of diff eqs in
% dxdt
% Number of states must equal number of DAEs in dxdt

x_QVdroop=x(1:3); % internal states gi, no specific name
Qcmd=x(4);
Iqcmd=x(5); 
Ipcmd=x(6);
w=x(7);
Pcmd=x(8);
x_phys=x(9:10); % internal states gi
Ipterm=x(11);
Iqterm=x(12);
Vterm=x(13); 
Vterm_theta=x(14);
Pt=x(15);
Qt=x(16);
Vref=x(17);

% DAEs
inverter_dxdt=[
    QVdroop(x_QVdroop,Vterm,Vref,Qcmd,params); % 4 diff eq, g1/g2/g3/Qcmd
    current_control2(Qcmd,Pt,Vterm,Iqcmd,Ipcmd,Pcmd,params); % 2 diff eq, 3 alg, mixed ordering
    physConv(x_phys,Ipcmd,Iqcmd,Ipterm,Iqterm,params); % 2 diff eq, 2 alg, g1/g2/Ipterm/Iqterm
    infBusNwk(Ipterm,Iqterm,Vterm,Vterm_theta,Pt,Qt,params); % 2 alg, Pline/Qline
    0; % d(Vref)=0
    ];
end
