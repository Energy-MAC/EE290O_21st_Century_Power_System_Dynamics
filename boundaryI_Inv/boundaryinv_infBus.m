% Version WITH triple integrator in inverter model compared to
% boundaryinv_infBus2
%--------------------------------------------
% Create simple circuit, inverter, RLC load, gnd
function inverter_dxdt=boundaryinv_infBus(t,x,params,Ts)
% Note: everything passed into a sub function must be a param or a state!
% Note: order of states is exactly alligned with ordering of diff eqs in
% dxdt
% Number of states must equal number of DAEs in dxdt
% Note: "DAE appears to be of index greater than 1" >> could mean you have a
% second order diff eq from "stacking of vars"

x_QVdroop=x(1:3); % internal states gi, no specific name
Qcmd=x(4);
x_Ictrl(1)=x(5);% internals states gi
Ipcmd=x(6);
Iqcmd=x(7); 
w=x(8);
Pcmd=x(9);
x_phys=x(10:11); % internal states gi
Ipterm=x(12);
Iqterm=x(13);
Vterm=x(14); 
Vterm_theta=x(15);
Pt=x(16);
Qt=x(17);
Vref=x(18);

% DAEs
inverter_dxdt=[
    QVdroop(x_QVdroop,Vterm,Vref,Qcmd,params); % 4 diff eq, g1/g2/g3/Qcmd
    current_control(x_Ictrl,Qcmd,Iqterm,Vterm,Iqcmd,Ipcmd,Vterm_theta,Pcmd,w,params); % 2 diff eq, 3 alg, mixed ordering
    physConv(x_phys,Ipcmd,Iqcmd,Ipterm,Iqterm,params); % 2 diff eq, 2 alg, g1/g2/Ipterm/Iqterm
    infBusNwk(Ipterm,Iqterm,Vterm,Vterm_theta,Pt,Qt,params); % 2 alg, Pline/Qline
    0; % d(Vref)=0
    ];
end
