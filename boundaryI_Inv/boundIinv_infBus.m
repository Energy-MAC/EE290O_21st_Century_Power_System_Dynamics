% Create simple circuit, inverter, RLC load, gnd

%% Need to set these...
% Vmeas
% Vref
% Vslow
% Qgen
% Pord
% Vterm

% Load params
% foo

%% Create combined inv model
% using series MATLAB func reference: https://www.mathworks.com/help/control/ref/series.html
sys1= QVdroop(Vmeas, Vref, Vslow, params)
sys2= current_control(Qcmd, Qgen, Pord, Vterm, params)
sys3= physConv(Ipcmd,Iqcmd,Vterm, params)

% double check I/O to make sure connecting right terminals
sys1.InputName
sys1.OutputName
sys2.InputName
sys2.OutputName
sys3.InputName
sys3.OutputName
sys12=series(sys1,sys2,[1],[1]) % connect 1st output to 1st input
combinedSys=series(sys12,sys3,[1 2],[1 2]) % connect the only 2 outputs to the only 2 inputs

% Once ready, should be able to solve combinedSys with ODE45:
% https://www.mathworks.com/matlabcentral/answers/146782-solve-state-space-equation-by-ode45