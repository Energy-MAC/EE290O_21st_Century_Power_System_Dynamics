%
%  Solve differential equations for Generator-Infinite Bus with and without AVR:
%  Voltage recovery example 
%

%
%  Basic data:
%
% a) Event times
%
clear all
global t1
t1=1;     % Apply contigency: Increase line impedance Xl
t3=10;    % End of integration

%
% b) System initial data
%
global Xl Xth Xg M D Kv Pd V1o V Eo;
Xl=0.5;
Xth=0.25;
Xg=0.25;
V1o=1;
V=1;
M=0.1;    
D=0.1;  
Pd=0.9;
Kv=10; % AVR gain
Eo=1;  % No AVR set point

%
% c) Find intial equilirium point:
%
% - System with AVR:
z0=fsolve(@GIFAVRpfeqs,[0 1 0],optimset('fsolve'))
d0=z0(1);  
E0=z0(2);
z0=[0 d0 E0].';

% - System without AVR:
d0p=fsolve(@GIFnoAVRpfeqs,0,optimset('fsolve'))
z0p=[0 d0p].';


%
% d) Time solution (integration):
%
% - System with AVR:
[t,z]=ode23t(@GIFAVReqsVR,[0:0.001:t3],z0);
w=z(:,1);  
d=z(:,2);  
E=z(:,3);

N=length(t);
for i=1:N, 
  if t(i) < t1, Xlp = Xl; else Xlp = Xl+0.1; end;
  X=Xlp+Xg+Xth;
  V1i= E(i)*(Xth+Xlp)/X*sin(d(i));
  V1r= V*(1 - (Xth+Xlp)/X) + E(i)*(Xth+Xlp)/X*cos(d(i));
  V1(i)= sqrt(V1r.^2+V1i.^2);
  V3i= E(i)*Xth/X*sin(d(i));
  V3r= V*(1 - Xth/X) + E(i)*Xth/X*cos(d(i));
  V3(i)= sqrt(V3r.^2+V3i.^2);
end

% - System without AVR:
[tp,zp]=ode23t(@GIFnoAVReqsVR,[0:0.001:t3],z0p);
wp=zp(:,1);  
dp=zp(:,2);  

N=length(tp);
for i=1:N, 
  if tp(i) < t1, Xlp = Xl; else Xlp = Xl+0.1; end;
  X=Xlp+Xg+Xth;
  V1pi= Eo*(Xth+Xlp)/X*sin(dp(i));
  V1pr= V*(1 - (Xth+Xlp)/X) + Eo*(Xth+Xlp)/X*cos(dp(i));
  V1p(i)= sqrt(V1pr.^2+V1pi.^2);
  V3pi= Eo*Xth/X*sin(dp(i));
  V3pr= V*(1 - Xth/X) + Eo*Xth/X*cos(dp(i));
  V3p(i)= sqrt(V3pr.^2+V3pi.^2);
end


%
% e) Plot results:
%
figure;
plot(t,V1,'k-.',t,V3,'b:',tp,V1p,'r-',tp,V3p,'b--');
legend('V_1 AVR','V_3 AVR','V_1 No AVR','V_3 No AVR');
ylabel('[pu]');
xlabel('t [s]');
%zoom;
