% Version removes triple integrator from inverter model compared to
% current_control.m
function f = current_control2(Qcmd,Pt,Vterm,Iqcmd,Ipcmd,Pcmd,params)
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

%ws=params.ws;
Tfrq=params.Tfrq;
Kwi=params.Kwi;
%Vterm_theta_ref=params.Vterm_theta_ref;
kphi=params.kphi; % associated with 60Hz, see equations for derivation
Pnom=params.Pnom;

% x(5) to x(8)
kphi=60; % associated with 60Hz, see equations for derivation
f=[
    % Algebraic:
    %0=
    Qcmd/Vterm-Iqcmd; % Set Iqcmd
    
    % Algebraic:
    %0=
    Pcmd/Vterm-Ipcmd; % Set Ipcmd
    
    % Algebraic:
    % 0=
    0; % set w constant because converter operation doesn't affect grid freq
    
    % d(Pcmd)/dt= 
    Kwi*(Pt-Pnom);
];
end
