function infbus = load_infbus(case_name)
% First column of M_loads is bus index, second is resistance, third is conductance at each bus

case_dir = 'cases';
load_file = sprintf('%s/%s/infbus_data.csv',case_dir,case_name);

try
    infbus = csvread(load_file, 1,1);
catch
    warning('No inf_bus file data was able to be loaded');
    infbus = [];
end
