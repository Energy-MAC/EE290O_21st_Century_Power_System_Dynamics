function [F]=fun(z)
%
%  Power flow equations for Generator-Infinite Bus example without AVR
%
global Xl Xth Xg Pd V Eo

%
% Variables:
%
d=z(1);  

%
% Power fow equations:
%
X= Xl+Xg+Xth;

F = Pd - Eo*V/X*sin(d);

