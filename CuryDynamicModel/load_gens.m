function gens = load_gens(case_name)
% First column of M_loads is bus index, second is resistance, third is conductance at each bus

case_dir = 'cases';
load_file = sprintf('%s/%s/gen_data.csv',case_dir,case_name);

try
    gens = csvread(load_file, 1,1);
catch
    warning('No gens file data was able to be loaded');
    gens = [];
end
