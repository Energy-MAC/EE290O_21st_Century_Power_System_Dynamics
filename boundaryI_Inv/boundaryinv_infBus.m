% Create simple circuit, inverter, RLC load, gnd
function inverter_dxdt=boundaryinv_infBus(x,params);

% Internal states of each block
% Note: everything passed into a sub function must be a param or a state!
x_QVdroop=x(1:3) % internal states gi, no specific name
Vg=x(4);
Vref=x(5);
Qcmd=x(6);
x_Ictrl=x(7)% internals states gi
Qgen=x(8);
Iqcmd=x(9);
Ipcmd=x(10);
x_phys=x(11:12); % internal states gi
Iqterm=x(13);
Ipterm=x(14);
I1=x(15);
I2=x(16);


inverter_dxdt=[
% DAEs
    QVdroop(x_QVdroop,Vg, Vref,Qcmd,params); % 4 diff eq
    current_control(x_Ictrl,Qcmd, Qgen,Iqcmd, Ipcmd, params); % 2 diff eq, 1 alg
    physConv(x_phys,Ipcmd,Iqcmd,Iqterm,Ipterm,params); % 2 diff eq, 1 alg
    infBusNwk(Ipterm,Iqterm,Vg,I1,I2,params);
    ];

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