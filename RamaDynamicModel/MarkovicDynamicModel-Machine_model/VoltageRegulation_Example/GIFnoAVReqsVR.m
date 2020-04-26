function [F]=fun(t,z)
%
%  DAEs for Generator-Infinte Bus example with AVR
%
global t1
global Xl Xth Xg M D Pd Eo V

%
%  Basic data:
%
if t<t1,        % Pre-contingency
  Xl1=Xl;
else            % Contingency
  Xl1=0.1+Xl; 
end;
X=Xl1+Xg+Xth;

%
% Variables:
%
w=z(1);  
d=z(2);  

%
% Nonlinear ODEs:
%
dwdt = 1/M *(Pd - Eo*V/X*sin(d) - D*w);
dddt = w;

F=[dwdt dddt].';
