function f = current_control(x_Ictrl,Qcmd, Qgen,Vterm,Iqcmd, Ipcmd,params)
% Function returns the sys in state space form, to be concatenated with
% other subsystems of in the inverter
% Inputs: [Qcmd, Qgen]
    % unclear what Qgen is
    % Vterm is a constant, but here treating as an input to the func
% Outputs: [Iqcmd, Ipcmd]

% Params that form the "boundary current" limits
% Iqmin=params.Iqmin % not used yet
% Iqmax=params.Iqmax % not used yet
% Ipmax=params.Ipmax % not used yet
Kvi=params.Kvi
Kqi=params.Kqi
Pord=params.Pord

% % See handwritten work for derivation of state space form from GE PV
% % inverter paper "Solar Photovoltaic (PV) Plant Models in PSLF"
% A=[0 0;...
%     Kvi 0];
% B=[KQi -KQi 0;...
%     0 0 0];
% C=[0 1];
% D=[0 0 1/Vterm];
% 
% % naming is needed for concatenation
% mySys=ss(A,B,C,D,'InputName',{'cur_Qcmd','cur_Qgen','cur_Pord'},'OutputName',{'Iqcmd','Ipcmd'});

g1=x_Ictrl(1)

f=[
    % Differential:
    %d(g1)/dt=
    Kqi*(Qcmd-Qgen);
    % d(g2)/dt=
    Kvi*(g1-Vterm);

    % Algebraic:
    %0=
    Pord/Vterm-Ipcmd;
];
end