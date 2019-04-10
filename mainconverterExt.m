


M_convertersDC = ones(2,2);
M_convertersAC = ones(2,2);

% Construct parameters

%Initialization
converters_size = size(M_convertersDC, 1); % number of lines
omega0 = 120*pi; %nominal angular frequency
j = [cos(pi/2), -sin(pi/2); sin(pi/2) , cos(pi/2)]; % Rotational matrix of pi/2.

%Construct converter matrices
Gdc_converters = diag(M_convertersDC(:,1));
Cdc_converters = diag(M_convertersDC(:,2));
Rac_converters = zeros(2*converters_size, 2*converters_size);
Lac_converters = zeros(2*converters_size, 2*converters_size);
Zac_converters = zeros(2*converters_size, 2*converters_size);
%this does the Kroenecker product
for i=1:converters_size %For each line     
   rac_converteri = M_convertersAC(i,1); %resistance of line i
   lac_converteri = M_convertersAC(i,2); %inductance of line i   
   Rac_converters(2*i-1:2*i, 2*i-1:2*i) = rac_converteri*eye(2); %AC resistance Matrix of converter i
   Lac_converters(2*i-1:2*i, 2*i-1:2*i) = lac_converteri*eye(2); %AC Inductance Matrix of converter i
   Zac_converters(2*i-1:2*i, 2*i-1:2*i) = Rac_converters(2*i-1:2*i, 2*i-1:2*i) ...
       + j*omega0*Lac_converters(2*i-1:2*i, 2*i-1:2*i); %AC Impedance Matrix of converter i 
end
inv_Cdc_converters = inv(Cdc_converters);
inv_Lac_converters = inv(Lac_converters);

%ode_convertersDC_modular(t,y, Gdc_converters, inv_Cdc_converters)
%ode_convertersAC_modular(t,y, Zac_converters, inv_Lac_converters)



%{
%%test
v_convertersonly = [1 0 1 0]';
ic = [1 0 1 0]';
idc = [1 1]';
vdc = [1 1]';
m = [0 0 0 0]';

dic_dt = di_converters_dt(v_convertersonly, ic, vdc, m, Zac_converters, inv_Lac_converters)
dvdc_dt = dvdc_converters_dt(idc, ic, vdc, m, Gdc_converters, inv_Cdc_converters)
%}







