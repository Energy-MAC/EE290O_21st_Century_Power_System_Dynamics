function [F]=ini_pf(x)

d=x(1);  
E=x(2);
d1=x(3);

if E<0
    error("Rotor Generator Voltage is not a valid value")
end

% Power fow equations:

X= Xl+Xg+Xth;

f1 = Pd - E*V/X*sin(d);
f2 = Pd - V1o*V/(Xl+Xth)*sin(d1);
f3 = V^2*(1/(Xl+Xth) - 1/X) - V1o*V/(Xl+Xth)*cos(d1)+ E*V/X*cos(d);

F=[f1 f2 f3];