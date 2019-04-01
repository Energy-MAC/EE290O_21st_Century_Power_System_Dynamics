function Q_cmd = QVdroop(Vmeas, Vref, Vslow, params)
% Inputs: Vmeas, Vref, Vslow
% Vslow omitted for now, involves detuning controller in the case of
% multiple actuators causing adverse interactions

% Params: Tc,Tr,Tv,Vfrz
% delay constants are for control,meas,and ? respectively
% Vfrz ommitted for now, involves freezing the inverter if voltage gets too
% low, perhaps something like ant-windup action

% Outputs: Q_cmd
% -----------------------------------------------

% Set parameters
Tc=params.Tc
Tr=params.Tr
Tv=params.Tv
Vfrz=params.frz % not used for now

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

mySys=ss(A,B,C,[]);