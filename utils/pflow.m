 function S=pflow(S)

%Initial conditions 

x0=init(S);

f = @(x)pfloweqs(x,S);

pfsol = fsolve(f,x0,(optimset('Algorithm','trust-region-reflective','Display','iter','TolFun',1e-15)));
S=record(pfsol,S);

%delete('pfloweqs.m')

end

function x = init(S) 

x=zeros(2*S.Bus.n,1);


%Function for reading the initial conditions of the Power Flow from the structure 

%Initial Conditions for Slack Bus

for k= S.Bus.SlackList
    x(k)= real(S.Bus.Generation(S.Bus.SlackList));
    x(k+1)=imag(S.Bus.Generation(S.Bus.SlackList));
end
 
%Initial conditions for PQ Buses 

for k = S.Bus.PQList
    
    x(2*k -1) = S.Bus.Voltages(k);
    x(2*k) = S.Bus.Angles(k)/(180/pi());
end

%Initial conditions for PV Buses 

for k = S.Bus.PVList
    
    x(2*k -1) = imag(S.Bus.Load(k))-imag(S.Bus.Generation(k));
    x(2*k)=S.Bus.Angles(k)/(180/pi());
end

end


function S=record(pfsol,S)

%Write Results for Slack Bus

for k= S.Bus.SlackList
    S.Bus.Generation(k) = pfsol(k)+1i*pfsol(k+1);
    S.Machine.MW(k)=pfsol(k)*S.BaseMVA;
    S.Machine.MVAR(k)=pfsol(k+1)*S.BaseMVA;
end
 
%Write Results for PQ Buses 

for k = S.Bus.PQList
    S.Bus.Voltages(k)=pfsol(2*k -1);
    S.Bus.Angles(k)=pfsol(2*k)*(180/pi());
end

%Write results for PV Buses 

for k = S.Bus.PVList
    S.Bus.Generation(k)=real(S.Bus.Generation(k))+j*pfsol(2*k -1);
    S.Bus.Angles(k)=pfsol(2*k)*(180/pi());
    S.Machine.MVAR(S.Machine.newGen(k))=pfsol(2*k -1)*S.BaseMVA;
end


end


