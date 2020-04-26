%Builds the Jacobian


PjacANG = zeros(length(YBus), length(YBus));
QjacANG = zeros(length(PQindex), length(YBus));

PjacV = zeros(length(YBus), length(PQindex));
QjacV = zeros(length(PQindex), length(PQindex));

%PV Angle builder
for indexA = 1:(length(YBus))
    for indexB = 1:length(YBus)
        if (indexA == indexB)
           PjacANG(indexA, indexB) = -Q(indexA) - imag(YBus(indexA,indexB)) .* (V(indexA).^2);
        else           
            PjacANG(indexA, indexB) = V(indexA).*V(indexB).* (real(YBus(indexA,indexB)).*sin(ANG(indexA)-ANG(indexB)) - imag(YBus(indexA,indexB)).*cos(ANG(indexA) - ANG(indexB)));
        end
    end
end

%PQ Angle builder
for indexA = PQindex(1):PQindex(end)
    for indexB = 1:(length(YBus))
        if (indexA == indexB)
           QjacANG(find(PQindex == indexA), indexB) = P(indexA) - real(YBus(indexA,indexB)) .* (V(indexA).^2);

        else                       
            QjacANG(find(PQindex == indexA), indexB) = -V(indexA).*V(indexB).* (real(YBus(indexA,indexB)).*cos(ANG(indexA)-ANG(indexB)) + imag(YBus(indexA,indexB)).*sin(ANG(indexA) - ANG(indexB)));
           
        end          
    end
end

%PV Voltage builder
for indexA = 1:(length(YBus))
    for indexB = PQindex(1):PQindex(end)
        if (indexA == indexB)
            PjacV(indexA, find(PQindex == indexB)) = P(indexA)/V(indexA) + real(YBus(indexA,indexB)) .* V(indexA);
        else
            PjacV(indexA, find(PQindex == indexB)) = V(indexA).* (real(YBus(indexA,indexB)).*cos(ANG(indexA)-ANG(indexB)) + imag(YBus(indexA,indexB)).*sin(ANG(indexA) - ANG(indexB)));
        end
    end
end

%PQ Voltage builder
for indexA = PQindex(1):PQindex(end)
    for indexB = PQindex(1):PQindex(end)
        if (indexA == indexB)
           QjacV(find(PQindex == indexA), find(PQindex == indexB)) = Q(indexA)/V(indexA)- imag(YBus(indexA,indexB)) .* V(indexA);
        else           
            QjacV(find(PQindex == indexA), find(PQindex == indexB)) = V(indexA).* (real(YBus(indexA,indexB)).*sin(ANG(indexA)-ANG(indexB)) - imag(YBus(indexA,indexB)).*cos(ANG(indexA) - ANG(indexB)));   
        end          
    end
end


%combines the P's together
fullJac = [ PjacANG(2:end,2:end),PjacV(2:end,:) ;  QjacANG(:,2:end),QjacV];