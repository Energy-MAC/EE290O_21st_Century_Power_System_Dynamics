function mySys = QVdroop(Vmeas, Vref, Vslow, params)
% Function returns the sys in state space form, to be concatenated with
% other subsystems of in the inverter

% Inputs, outputs, and params of state space rep:
    % Inputs: [Vmeas, Vref]
    % Vslow omitted for now, involves detuning controller in the case of
    % multiple actuators causing adverse interactions
% Outputs: [Q_cmd]
% -----------------------------------------------

% Set parameters
Tc=params.Tc % communications and actuation delay
Tr=params.Tr % meas delay
Tv=params.Tv % unsure
Vfrz=params.frz % ommitted for now, involves freezing the inverter if voltage gets too low, perhaps something like ant-windup action

% See handwritten work for derivation of state space form from GE PV
% inverter paper "Solar Photovoltaic (PV) Plant Models in PSLF"
A=[-1/Tr 0 0 0;...
    -Kp/Tv -1/Tv 0 0;...
    0 1/Tc -1/Tc 1/Tc;...
    -Ki 0 0 0];
B=[1/Tr 0;...
    0 Kp/Tv;...
    0 0;...
    0 Ki];
C=[0 0 1 0]';

% naming is needed for concatenation
mySys=ss(A,B,C,[],'InputName',{'dr_Vmeas','dr_Vref'},'OutputName',{'dr_Qcmd'});

