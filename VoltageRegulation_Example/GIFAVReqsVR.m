function [F]=fun(t,z)
%
%  DAEs for Generator-Infinte Bus example with AVR
%
global t1
global Xl Xth Xg M D Kv Pd V1o V

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
E=z(3);


V1i= E*(Xl1+Xth)/X*sin(d);
V1r= V*(1 - (Xl1+Xth)/X) + E*(Xl1+Xth)/X*cos(d);
V1=sqrt(V1r^2+V1i^2);

if E<0, E=0; end;

%
% Nonlinear ODEs:
%
dwdt = 1/M *(Pd - E*V/X*sin(d) - D*w);
dddt = w;
dEdt =  Kv* (V1o - V1);
if E==0,  dEdt=0; end;

F=[dwdt dddt dEdt].';
