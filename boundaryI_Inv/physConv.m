function f = physConv(x_phys,Ipcmd,Iqcmd,Ipterm,Iqterm,params)
% Physical converter model is a constant current source Iterm with shunt
% reactance Xlcl, where Iterm is computed from a bunch of limiting
% characteristic curves

% Inputs: Ipcmd,Iqcmd,Vterm
% Outputs: Iterm

% Set parameters
Tpwm=params.Tpwm; % delay for PWM switiching
% KHV % placeholder for high voltage management curve
    % ^ reduces reacive current injection to limit Vterm to 120%
% KLV % placeholder for low voltage management curve
    % ^ linear reduction of active current injection for terminal V below
    % 0.8pu
%params.K_LPVL % placeholder for limiting Pmax from low V management curve

Ipmax=params.Ipmax;
Iqmax=params.Iqmax;
Ipmin=params.Ipmin;
Iqmin=params.Iqmin;

% Diff Eqs or alg eqs go here
g1=x_phys(1);
g2=x_phys(2);

f=[
    % Differential:
    %d(g1)/dt=
    (1/Tpwm)*(Iqcmd-g1);
    % d(g2)/dt=
    (1/Tpwm)*(Ipcmd-g2);

    % If want to limit current output:
%     %0=
%     max(min(g2,Ipmax),Ipmin)-Ipterm; % limit by min and max
%     %0=
%     max(min(g1,Iqmax),Iqmin)-Iqterm;

    % If DONT want to limit current output:
    %0=
    g2-Ipterm; % limit by min and max
    %0=
    g1-Iqterm;
];
end

