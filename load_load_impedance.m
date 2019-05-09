function M_loads = load_load_impedance(case_name)
% First column of M_loads is bus index, second is resistance, third is conductance at each bus

case_dir = 'cases';
load_file = sprintf('%s/%s/zip_load_data.csv',case_dir,case_name);
omega = 120*pi; %60 Hz

M_loads = zeros(0,4);
try
    M_loads = csvread(load_file, 1,0);
catch
    warning('No load file data was able to be loaded');
end

if any(M_loads(:,4) ~= 1)
    error('Loads must be constant impedance at this time');
end

M_loads = M_loads(:,1:3);

% Calculate impedane from power
%M_loads(:,[2 3]) = M_loads(:,[2 3])./vecnorm(M_loads(:,[2 3]),2,2);
% Divide reactance by frequency to get inductance
M_loads(:,3) = M_loads(:,3)/omega;
