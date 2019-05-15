%Phillippe Phanivong
% Builds the P,Q, V, ANG vectors

clc; close all;
%reads from a .xlsx file
[Bus,Type,V,ANG,Pgen,Qgen,Pload,Qload] = PowerReader('System2 Power.xlsx',1,2,13 ); %'System1 Power.xlsx',1,2,5   %'System2 Power.xlsx',1,2,13 % 'System3 Power.xlsx',1,2,4


    