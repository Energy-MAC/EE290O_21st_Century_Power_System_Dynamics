function [FromNode,ToNode,rpu,xpu,y2pu,ypu] = YbusReader(workbookFile,sheetName,startRow,endRow)
%IMPORTFILE Import data from a spreadsheet
%   [FromNode,ToNode,rpu,xpu,y2pu,ypu] = IMPORTFILE(FILE) reads data from
%   the first worksheet in the Microsoft Excel spreadsheet file named FILE
%   and returns the data as column vectors.
%
%   [FromNode,ToNode,rpu,xpu,y2pu,ypu] = IMPORTFILE(FILE,SHEET) reads from
%   the specified worksheet.
%
%   [FromNode,ToNode,rpu,xpu,y2pu,ypu] =
%   IMPORTFILE(FILE,SHEET,STARTROW,ENDROW) reads from the specified
%   worksheet for the specified row interval(s). Specify STARTROW and
%   ENDROW as a pair of scalars or vectors of matching size for
%   dis-contiguous row intervals. To read to the end of the file specify an
%   ENDROW of inf.%
% Example:
%   [FromNode,ToNode,rpu,xpu,y2pu,ypu] =
%   importfile('System2.xlsx','Sheet1',2,27);
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
    endRow = 27;
end

%% Import the data
data = xlsread(workbookFile, sheetName, sprintf('A%d:F%d',startRow(1),endRow(1)));
for block=2:length(startRow)
    tmpDataBlock = xlsread(workbookFile, sheetName, sprintf('A%d:F%d',startRow(block),endRow(block)));
    data = [data;tmpDataBlock]; %#ok<AGROW>
end

%% Allocate imported array to column variable names
FromNode = data(:,1);
ToNode = data(:,2);
rpu = data(:,3);
xpu = data(:,4);
y2pu = data(:,5);
ypu = data(:,6);

