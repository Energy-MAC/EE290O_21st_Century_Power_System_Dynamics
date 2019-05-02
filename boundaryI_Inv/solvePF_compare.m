% Next steps:
% work out pu for inv model, since this is 1vpu and 100Sbase
% connect inv model to this one, create boundayinv_network2

clc; clear all; close all;


%% Create meas from trace    
% create 2N nonlin algebriac equations, where n is number of nodes; each node has 2 unknowns
% Slack bus: know [V del], dont know [P Q]
% Gen bus: know [P V], dont know [del Q]
% Load bus: know [P Q], dont know [V del]

caseName='case5';
c = loadcase(caseName);
N = size(c.bus,1);

h_V=@(x,M_k) trace(M_k*x*x'); % note Tr(Mk*x*x')=V^2, not V!
h_P=@(x,Y_k) trace(Y_k*x*x');
h_Q=@(x,Ybar_k) -trace(Ybar_k*x*x');
[M_k,Y_k,Ybar_k,Y_lm,Ybar_lm,Y_ml,Ybar_ml]=computeYmats(c)

% Known values, hard to generalize by pulling from c
vmagVec=[1 0.989 1 1 1]';
thetaVec_deg=[3.273 -0.759 -0.492  0 4.112]'; % degrees
thetaVec=thetaVec_deg*(pi/180); % convert to radians

% use starting voltages to build x0
stateLabel=[];
% state vec x contains unknowns for every bus type
  for k = 1:N % creat 2*N bus equations
            busType=c.bus(k,2);
            switch busType % take different measurements at diff bus types
                case 1 % slack bus
                    x0(2*k-1)=h_P([vmagVec; thetaVec],Y_k{k}); % P
                    x0(2*k)=h_Q([vmagVec; thetaVec],Ybar_k{k}); % Q
                    stateLabel=[stateLabel 'P ' 'Q ']
                case 2 % gen bus 
                    x0(2*k-1)=thetaVec(k); % del
                    x0(2*k)=h_Q([vmagVec; thetaVec],Ybar_k{k}); % Q
                    stateLabel=[stateLabel 'del ' 'Q ']
                case 3 % load bus
                    x0(2*k-1)=vmagVec(k); % V
                    x0(2*k)=thetaVec(k); % del
                    stateLabel=[stateLabel 'V ' 'del ']
            end
  end
 % boundaryinv_network(0,x0) this is a first check
 x00= fsolve(@(x)boundaryinv_network(0,x,c),x0);
 printmat([x0' x00'], 'Init States', stateLabel,'x0 x00')

 %%
 % Key: instead of using symbolics, use x states you read in and set
 % numeric values (knowns) to everything else
 
 % "If you want to try to solve this system of
 % equations symbolically use the solve
 % function from Symbolic Math Toolbox.
 % If you want to try to solve this numerically,
 % either try the vpasolve function also from 
 % Symbolic Math Toolbox or convert the sym 
 % objects computed inside your function to 
 % double before you return them from your 
 % function to fsolve."
 
 % What is the inpt to solving power flow? You initialize with a guess of
 % complex nodal voltages, and from that guess produce the
 
 % Review of Power Flow: process is done in HW2
 % Inputs: "known" vars for each bus type
 % How it works: initialize with complex v_guess, and use functions between
 % known vars and z to determine z. z is the true set of complex voltages.
 % Once determined, use the functions to compite the unknown vars
 % Outputs: "unknown" vars for each bus type Goal of solving power flow is to determine the complex voltages at all m