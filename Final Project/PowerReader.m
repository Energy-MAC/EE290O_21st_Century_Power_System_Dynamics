function [Bus,Type,Volt,Ang,Pgen,Qgen,Pload,Qload] = PowerReader(workbookFile,sheetName,startRow,endRow)
%IMPORTFILE Import data from a spreadsheet
%   [BusNumber,Type,Voltagepu,Anglerad,Pgenpu,Qgenpu,Ploadpu,Qloadpu] =
%   IMPORTFILE(FILE) reads data from the first worksheet in the Microsoft
%   Excel spreadsheet file named FILE and returns the data as column
%   vectors.
%
%   [BusNumber,Type,Voltagepu,Anglerad,Pgenpu,Qgenpu,Ploadpu,Qloadpu] =
%   IMPORTFILE(FILE,SHEET) reads from the specified worksheet.
%
%   [BusNumber,Type,Voltagepu,Anglerad,Pgenpu,Qgenpu,Ploadpu,Qloadpu] =
%   IMPORTFILE(FILE,SHEET,STARTROW,ENDROW) reads from the specified
%   worksheet for the specified row interval(s). Specify STARTROW and
%   ENDROW as a pair of scalars or vectors of matching size for
%   dis-contiguous row intervals. To read to the end of the file specify an
%   ENDROW of inf.
%
%	Non-numeric cells are replaced with: NaN
%
% Example:
%   [BusNumber,Type,Voltagepu,Anglerad,Pgenpu,Qgenpu,Ploadpu,Qloadpu] =
%   importfile('System2 Power.xlsx','Sheet1',2,13);
%
%   See also XLSREAD.


%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 3
    startRow = 2;
    endRow = 13;
end

%% Import the data
[~, ~, raw] = xlsread(workbookFile, sheetName, sprintf('A%d:H%d',startRow(1),endRow(1)));
for block=2:length(startRow)
    [~, ~, tmpRawBlock] = xlsread(workbookFile, sheetName, sprintf('A%d:H%d',startRow(block),endRow(block)));
    raw = [raw;tmpRawBlock]; %#ok<AGROW>
end
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,2);
raw = raw(:,[1,3,4,5,6,7,8]);

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
Bus = data(:,1);
Type = cellVectors(:,1);
Volt = data(:,2);
Ang = data(:,3);
Pgen = data(:,4);
Qgen = data(:,5);
Pload = data(:,6);
Qload = data(:,7);

