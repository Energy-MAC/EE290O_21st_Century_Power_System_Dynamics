function f = physConv(Ipcmd,Iqcmd,Vterm,...
    Iterm,...
    params)
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
g1=x_phys(1)
g2=x_phys(2)

% Differential:
%d(g1)/dt=
(1/Tpwm)*(Iqcmd-g1);
% d(g2)/dt=
(1/Tpwm)*(Ipcmd-g2);

% Algebraic:
%0=
1*x_phys(1)+1*x_phys(2)-Iterm;