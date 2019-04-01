function mySys = physConv(Ipcmd,Iqcmd,Vterm, params)
% Physical converter model is a constant current source Iterm with shunt
% reactance Xlcl, where Iterm is computed from a bunch of limiting
% characteristic curves

% Inputs: Ipcmd,Iqcmd,Vterm
% Outputs: Iterm

% Set parameters
Tpwm=params.Tpwm % delay for PWM switiching
params.Khv % placeholder for high voltage management curve
params.Klv % placeholder for low voltage management curve
params.K_LPVL % placeholder for limiting Pmax from low V management curve
params.Xlcl % reactance of LCL filter

% Diff Eqs or alg eqs go here

 % Need to populate
mySys=ss([],[],[],[],'InputName',{'Iqcmd','Ipcmd'},'OutputName',{'Iterm'});
