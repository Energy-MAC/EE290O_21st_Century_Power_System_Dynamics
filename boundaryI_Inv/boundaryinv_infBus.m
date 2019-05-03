% Create simple circuit, inverter, RLC load, gnd
function inverter_dxdt=boundaryinv_infBus(t,x,params)
% Note: everything passed into a sub function must be a param or a state!
% Note: order of states is exactly alligned with ordering of diff eqs in
% dxdt
% Number of states must equal number of DAEs in dxdt

x_QVdroop=x(1:3); % internal states gi, no specific name
Qcmd=x(4);
x_Ictrl(1)=x(5);% internals states gi
Ipcmd=x(6);
Iqcmd=x(7); % new
w=x(8);
Pcmd=x(9);
Vterm_theta=x(10);
x_phys=x(11:12); % internal states gi
Ipterm=x(13);
Iqterm=x(14);
Pline=x(15);
Qline=x(16);
Vterm=x(17); 
Vref=x(18);

% DAEs
inverter_dxdt=[
    QVdroop(x_QVdroop,Vterm,Vref,Qcmd,params); % 4 diff eq, g1/g2/g3/Qcmd
    current_control(x_Ictrl,Qcmd,Vterm*Iqterm,Vterm,Iqcmd,Ipcmd,Vterm_theta,Pcmd,w,params); % 2 diff eq, 1 alg, g1/g2/Ipcmd
    physConv(x_phys,Ipcmd,Iqcmd,Ipterm,Iqterm,params); % 2 diff eq, 2 alg, g1/g2/Ipterm/Iqterm
    infBusNwk(Ipterm,Iqterm,Vterm,Vterm_theta,Pline,Qline,params); % 2 alg, Pline/Qline
    0; % d(Vterm)=0
    0; % d(Vref)=0
    ];
end



%% Create combined inv model for LTI sys
% % % using series MATLAB func reference: https://www.mathworks.com/help/control/ref/series.html
% % sys1= QVdroop(Vmeas, Vref, Vslow, params)
% % sys2= current_control(Qcmd, Qgen, Pord, Vterm, params)
% % sys3= physConv(Ipcmd,Iqcmd,Vterm, params)
% % 
% % % double check I/O to make sure connecting right terminals
% % sys1.InputName
% % sys1.OutputName
% % sys2.InputName
% % sys2.OutputName
% % sys3.InputName
% % sys3.OutputName
% % sys12=series(sys1,sys2,[1],[1]) % connect 1st output to 1st input
% % combinedSys=series(sys12,sys3,[1 2],[1 2]) % connect the only 2 outputs to the only 2 inputs

% Once ready, should be able to solve combinedSys with ODE45:
% https://www.mathworks.com/matlabcentral/answers/146782-solve-state-space-equation-by-ode45