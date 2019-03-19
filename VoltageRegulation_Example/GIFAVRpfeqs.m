function [F]=fun(z)
%
%  Power flow equations for Generator-Infinite Bus example with AVR
%
global Xl Xth Xg Pd V1o V

%
% Variables:
%
d=z(1);  
E=z(2);
d1=z(3);
if E<0, E=0; end;

%
% Power fow equations:
%
X= Xl+Xg+Xth;

f1 = Pd - E*V/X*sin(d);
f2 = Pd - V1o*V/(Xl+Xth)*sin(d1);
f3 = V^2*(1/(Xl+Xth) - 1/X) - V1o*V/(Xl+Xth)*cos(d1)+ E*V/X*cos(d);

F=[f1 f2 f3];
