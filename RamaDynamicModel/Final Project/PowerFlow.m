%NR Power Flow Solver
%Phillippe Phanivong


clc; clear all; close all;

%%
%read in data from .xls files
%build Ybus matrix 
%create P, Q, V, ANG Vectors
YbusBuilder;
PowerBuilder;

delx = 1;
itr = 0;
tol = 1e-4;

%creates a seperate matrix of Y w/o slack bus
YMat = YBus(2:end,2:end);

%creates a logical list for PQ buses
PQlist = zeros(length(YBus),1);
for a = 1:length(YBus)
    if (isequal( Type{a},'PQ'))
        PQlist(a)= 1;
    end
end
PQlist = logical(PQlist);
PQindex = find(PQlist);

P = zeros(length(YBus),1);
Q  = zeros(length(YBus),1);
Pmis = zeros(length(YBus),1);
Qmis  = zeros(length(YBus),1);

%%
%Create vectors of P & Q equations not including the slack bus
Pgen = nansum([Pgen, zeros(length(Pgen),1)],2);
Qgen = nansum([Qgen, zeros(length(Qgen),1)],2);



%Combined mismatch equations w/o slack bus and Q equations for PV buses

%%
%Sets up the flat start
% Set unknown Voltages and Angles to 1V 0 degrees
V = nansum([V,isnan(V)],2);

MismatchBuilder;



ANG = nansum([ANG, zeros(length(ANG),1)],2);

%%
%Jacobian builder

JacobiBuilder;


%%
%NR iterations

MAG = [ANG(2:end);nonzeros(V.*PQlist)];
disp('YBus: ');
disp(YBus);
while (max(abs(delx)) > tol) 
    itr = itr+1
    disp(' ');
    delx = -inv(fullJac)*impEQ
    disp(' ');
    MAG = MAG + delx;
    disp(' ');
    disp(' ');
    disp(['Max delx: ', num2str(max(abs(delx)))]);
    disp(' ');
    disp(' ');
    disp('Jacobian');
    disp(fullJac);
    disp('Voltage: ');
    disp(V);
    disp('Phase Angle (in radians):');
    disp(ANG);
    disp('');
    
    ANG(2:end)  =  MAG(1:length(ANG)-1);
    V(PQindex) = MAG(length(ANG):end);
    MismatchBuilder;
    JacobiBuilder;
    
end

