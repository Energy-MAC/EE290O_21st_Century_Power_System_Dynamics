% M-file accepts two arguments: t and y
% returns column vector dy

%function dy = power_controller(x_pwr_ctrl, Vt,Qg,omega,Pactual,[Iqcmd,
%Ipcmd], params)

%states: x_pwr_ctrl, Vt, Qg, omega, Pactual


function dy = power_controller(x_pwr_ctrl,Vt,Qg,omega,Pactual,params)
% Inputs, outputs, and params of state space rep:
    % Reference parameters (might have to move Qmax, Pmax if calculating
    % it based on Vt: [Vref, Qmax, Qmin, Pref, Pmax]
    % Inputs: [Vt,Qg,omega,Pactual] (measured from circuit) 
    % States: s1, s2, s3, s4, s5 (see Rama thesis) -> in vector x_pwr_ctrl
    % Outputs: [Iqcmd,Ipcmd]
        %these outputs get input to the inner current controller function
% -----------------------------------------------

%get reference parameters
Vref = params.Vref; % Voltage reference
Qmax = params.Qmax; % Max reactive power deliverable
Qmin = params.Qmin; % Min reactive power deliverable
Pref = params.Pref;
Pmax = params.Pmax;
%should calculate Qmax, Pmax based on Vt

%get all other parameters
Ki = params.Ki;
Rq = params.Rq;
Tr = params.Tr;
Kiq = params.Kiq;
Kip = params.Kip;
Kp = params.Kp;
TGpv = params.TGpv;
omega_s = params.omega_s;
Kip = params.Kip;

%x_pwr_control is an array that holds the states s1 - s5 as written in the
%Rama thesis
s1 = x_pwr_ctrl(1);
s2 = x_pwr_ctrl(2);
s3 = x_pwr_ctrl(3);
s4 = x_pwr_ctrl(4);
s5 = x_pwr_ctrl(5);

%pre-calculate Qcmd, Pcmd to populate array
Qcmd = s1 + Kp*(Vref - s2 - Rq*Qg);
Pcmd = s3;


dy = [
    
    %%% Differential equations:
    % Reactive power controller
    
    % ds1/dt = 
    Ki*(Vref - s2 - Rq*Qg);
    
    % ds2/dt = 
    (1/Tr)*(Vt-s2);
    
    % ds5/dt = 
    Kiq*(Qcmd - Qg);
    
   % Real power controller
    
    % ds3/dt = 
    (1/TGpv)*(Pref - ((omega - omega_s)/Rp) - s3);
    
    %ds4/dt = 
    Kip*(s3 - Pactual);  
    
    %%% Algebraic equations: 
    %0 = 
    Qcmd/Vt + s5 - IQcmd;
    
    Pcmd/Vt + s4 - IPcmd;
    
    ];
    
end

