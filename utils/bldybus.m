%----------------------------------------------------------------------------------------
function S = bldybus(S) %Esta funcione crea la matriz Ybus
Ybus = sparse(S.Bus.n, S.Bus.n);
YL = []; %Temporary Matrix for complex numbers. 
n= S.Bus.n;

if isempty(nonzeros(S.Branch.TAP -1))   
else
    S=PI_trans(S);
end

%Build Ybus. 

 if isfield(S.Bus, 'G'),
     YL = S.Bus.G;
 end
 
 if isfield(S.Bus, 'B'),
     YL = YL + 1i*S.Bus.B;
 end

  if isfield(S.Branch, 'YI'),
      Ybus=Ybus+sparse(S.Branch.From, S.Branch.From, S.Branch.YI,n,n);
  end
  
  if isfield(S.Branch, 'YJ'),
      Ybus = Ybus + sparse(S.Branch.To, S.Branch.To, S.Branch.YJ,n,n);
  end
 
 if ones(1,length(YL))*YL ~=0,
      Ybus = Ybus+diag(sparse(YL));
 
 else

  Y11 = (1./S.Branch.Z + (1i*S.Branch.B)/2).*S.Branch.Status;
  Ybus = Ybus+sparse(S.Branch.From, S.Branch.From, Y11,n,n);
  Y12 = (-1./(S.Branch.Z)).*S.Branch.Status;
  Ybus=Ybus+sparse(S.Branch.From, S.Branch.To, Y12,n,n);
  Y21 = (-1./S.Branch.Z).*S.Branch.Status;
  Ybus=Ybus+sparse(S.Branch.To, S.Branch.From, Y21,n,n);
  Y22 = (1./(S.Branch.Z)+(1i*S.Branch.B)/2).*S.Branch.Status;
  Ybus=Ybus+sparse(S.Branch.To, S.Branch.To, Y22,n,n);

 end

 S.Ybus=Ybus;
 
end

function S = PI_trans(S)

%Consider the effect of the taps usign the PI model. 
c=1./S.Branch.TAP;
S.Branch.YI=(1./S.Branch.Z).*c.*(c-1);
S.Branch.YJ=(1./S.Branch.Z).*(1-c);
S.Branch.Z=S.Branch.Z.*S.Branch.TAP;

end