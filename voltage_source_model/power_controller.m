% M-file accepts two arguments: t and y
% returns column vector dy

%function dy = power_controller(x_pwr_ctrl, Vt,Qg,omega,Pactual,[Iqcmd,
%Ipcmd], params)



function dy = power_controller(x_pwr_ctrl, Vt, Qg, omega, Pactual, IQcmd, IPcmd, params)
% Inputs, outputs, and params of state space rep:
    % Inputs: [Vt, Qg, omega, Pactual] (measured from circuit -> should come from power flow) 
    % Intermediate States: s1, s2, s3, s4, s5 (see Rama thesis) -> in vector x_pwr_ctrl
    % Outputs: [Iqcmd,IPcmd]
        %these outputs get input to the inner current controller function
% -----------------------------------------------

%get reference parameters
Vref = params.Vref; % Voltage reference
Pref = params.Pref; % Referene real power
% Qmax = params.Qmax; % Max reactive power deliverable
% Qmin = params.Qmin; % Min reactive power deliverable
% Pmax = params.Pmax; % Reference max power

%TODO: calculate Qmax, Pmax based on Vt, add limits
%Right now, ignoring P and Q limits

%get all other parameters
%gains
Ki = params.Ki;
Kiq = params.Kiq;
Kip = params.Kip;
Kp = params.Kp;
Kip = params.Kip;

%time constants
TGpv = params.TGpv;
Tr = params.Tr;

%damping coeffs
Rq = params.Rq;
Rp = params.Rp;

omega_s = params.omega_s;

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
    
    % ds1/dt = 
    Ki*(Vref - s2 - Rq*Qg);
    
    % ds2/dt = 
    (1/Tr)*(Vt-s2); 
   
    % ds3/dt = 
    (1/TGpv)*(Pref - ((omega - omega_s)/Rp) - s3);
    
    % ds4/dt = 
    Kip*(s3 - Pactual);  
    
    % ds5/dt = 
    Kiq*(Qcmd - Qg);
    
    %%% Algebraic equations: 
    % 0 = 
    Qcmd/Vt + s5 - IQcmd;
    
    % 0 = 
    Pcmd/Vt + s4 - IPcmd;
    
    ];
    
end

