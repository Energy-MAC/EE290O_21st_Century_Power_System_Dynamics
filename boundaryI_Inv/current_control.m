function f = current_control(x_Ictrl,Qcmd,Qgen,Vterm,Iqcmd,Ipcmd,Vterm_theta,Pcmd,w,params)
% Function returns the sys in state space form, to be concatenated with
% other subsystems of in the inverter
% Inputs: [Qcmd, Qgen]
    % Qgen=Iqterm*Vterm, the whole inverter Qoutput
    % Vterm is a constant, but here treating as an input to the func
% Outputs: [Iqcmd, Ipcmd]

% Params that form the "boundary current" limits
% Iqmin=params.Iqmin % not used yet
% Iqmax=params.Iqmax % not used yet
% Ipmax=params.Ipmax % not used yet
Kvi=params.Kvi;
Kqi=params.Kqi;
ws=params.ws;
Tfrq=params.Tfrq;
Kw=params.Kw;

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

g1=x_Ictrl(1);

f=[
    % Differential:
    %d(g1)/dt=
    Kqi*(Qcmd-Qgen);
    
    % Algebraic:
    %0=
    Pcmd/Vterm-Ipcmd;
    
    % Differential:
    % d(Iqcmd)/dt=
    Kvi*(g1-Vterm);
    % d(w)=
    0; % originally tried d(w)dt=g2, but this makes DAE second order
    
    % Algebraic:
    % 0=
    (-1/Kw)*(w-ws)-Pcmd; % Pcmd=

   % Differential:
    % d(Vterm_theta)=
    314.16*(w-ws); % change in torque (Milano eq 15.5 part 2)
];
end

% referring to pg 4 of this paper for w eqns: https://arxiv.org/pdf/1206.5033.pdf