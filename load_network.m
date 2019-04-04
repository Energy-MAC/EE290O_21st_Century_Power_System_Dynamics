function [M_lines,M_buses] = load_network(case_name,try_matpower)

% By default, look for a MATPOWER case with the name if one isn't found
if nargin < 2
    try_matpower = true;
end

case_dir = 'cases';

% First look for local files
if exist(sprintf('%s/%s',case_dir,case_name), 'dir')
    try
        M_lines = csvread(sprintf('%s/%s/line_data.csv',case_dir,case_name), 1,1); %Read line data as Matrix. 1,1 means that it skips the first row and first column
    catch
        error('Could not read line data');
    end
    try
        M_buses = csvread(sprintf('%s/%s/bus_data.csv',case_dir,case_name), 1,2); %Read bus data as Matrix. 1,2 means that skips first row and the two first columns
    catch
        error('Could not read bus data');
    end
elseif try_matpower
    try
        c = loadcase(case_name);
    catch
        error('Could not load MATPOWER case. Make sure MATPOWER is installed and on the path');
    end
    mkdir(sprintf('%s/%s',case_dir,case_name));
    % Build bus matrix; MATPOWER G and B given in units per MVA, converte
    % to p.u.
    M_buses = c.bus(:,[5 6])/c.baseMVA;
    % MATPOWER gives susceptance instead of capacitance; assume 60 Hz to
    % convert.
    M_buses(:,2) = M_buses(:,2)/(120*pi);
    
    % Write bus matrix
    N_buses = size(M_buses,1);
    to_write = cell2table([compose('Bus%d',(1:N_buses)') num2cell([(1:N_buses)' M_buses])],...
        'VariableNames',{'BusName','BusNumber','Conductance_pu','Capacitance_pu'});
    writetable(to_write,sprintf('%s/%s/bus_data.csv',case_dir,case_name));
    
    % Build line matrix
    M_lines = c.branch(:,[3 4 1 2]);
    % MATPOWER gives reactance instead of inductance; assume 60 Hz to
    % convert.
    M_lines(:,2) = M_lines(:,2)/(120*pi);
    
    % Write branch matrix
    to_write = cell2table([compose('Line%d%d',M_lines(:,[3 4])) num2cell(M_lines)],...
        'VariableNames',{'LineName','Resistance_pu','Inductance_pu','SendingBus','ReceivingBus'});
    writetable(to_write,sprintf('%s/%s/line_data.csv',case_dir,case_name));
else
    error('Could not find case data');
end

end