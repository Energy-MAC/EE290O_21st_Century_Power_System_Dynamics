%Phillippe Phanivong
% Admittance matrix builder
% This script reads in .txt files with the following format:
%
%       From Node | To Node  | r(pu)  | x(pu) | y/2(pu) | y(pu)
%           ##         ##       #.#      #.#      #.#     #.#
%           ##         ##       #.#      #.#      #.#     #.#
%           ##         ##       #.#      #.#      #.#     #.#
% 
clc; close all;


FROM_CONST = 1;
TO_CONST = 2;
R_CONST = 3;
X_CONST = 4;
Y_HALF_CONST = 5;
Y_CONST = 6;


%%
%Reads from txt files
% fileID = fopen('system1.txt');
% 
% N = 6;
% 
% 
% C_text = textscan(fileID, '%s', N, 'delimiter', '|');
% 
% C_data1 = textscan(fileID, '%f %f %f %f %f %f', 'CollectOutput', 1);
% 
% fclose(fileID);
% 
% rawMat = C_data1{1,1};
%%
%Reads from .xlsx files
[FromNode,ToNode,rpu,xpu,y2pu,ypu] = YbusReader('System2.xlsx',1,2,27 ); %'System1.xlsx',1,2,7   %'System2.xlsx',1,2,27 'System3.xlsx',1,2,6
rawMat = [FromNode,ToNode,rpu,xpu,y2pu,ypu];
%%
%builds the Ymat from the raw data
nodes = max(rawMat(1:end,1));

YBus = zeros(nodes);

for a = 1:size(rawMat,1)
    %calculates for each row the total admittance: 1/(r-jx) + y/2 + y 
    lineZ = rawMat(a, R_CONST) + 1j* rawMat(a,X_CONST);
    if (lineZ == 0)
        lineCalc = 0;
    else
        lineCalc = 1/lineZ;
    end
    calc = lineCalc + 1j* rawMat(a, Y_HALF_CONST) + 1j*rawMat(a, Y_CONST);
    
    %adds the calculated value to the diagonal for the From node in the Y matrix
    YBus(rawMat(a,FROM_CONST),rawMat(a,FROM_CONST)) = YBus(rawMat(a,FROM_CONST),rawMat(a,FROM_CONST)) + calc;
    
    %if the To node isn't zero then adds the calculated value to the
    %other node's diagonal, places the line impedances in their [To, From]
    %positions as well
    if (rawMat(a, TO_CONST) ~= 0)
        YBus(rawMat(a,TO_CONST),rawMat(a,TO_CONST)) = YBus(rawMat(a,TO_CONST),rawMat(a,TO_CONST)) + calc;
        
        YBus(rawMat(a,TO_CONST),rawMat(a,FROM_CONST)) = YBus(rawMat(a,TO_CONST),rawMat(a,FROM_CONST)) - lineCalc;
        
        YBus(rawMat(a,FROM_CONST),rawMat(a,TO_CONST)) = YBus(rawMat(a,FROM_CONST),rawMat(a,TO_CONST)) - lineCalc;
    end
    
end

clearvars -except YBus;

        
    