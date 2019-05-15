%Creates P and Q mismatch equations regardless of PQ or PV bus (Q of PV
%buses will be pruned after)


if (itr ~= 0) 
P = zeros(length(YBus),1);
Q  = zeros(length(YBus),1);
    for indexA = 1:(length(YBus))
            for indexB = 1:length(YBus)
                P(indexA) = P(indexA) +  V(indexA).*V(indexB).* (real(YBus(indexA,indexB)).*cos(ANG(indexA)-ANG(indexB)) + imag(YBus(indexA,indexB)).*sin(ANG(indexA) - ANG(indexB)));
                Q(indexA) = Q(indexA) +  V(indexA).*V(indexB).* (real(YBus(indexA,indexB)).*sin(ANG(indexA)-ANG(indexB)) - imag(YBus(indexA,indexB)).*cos(ANG(indexA) - ANG(indexB))) ;
            end
            Pmis(indexA) = P(indexA) - Pgen(indexA) + Pload(indexA);
            Qmis(indexA) = Q(indexA) - Qgen(indexA) + Qload(indexA);
    end
else

    for indexA = 1:(length(YBus))
        Pmis(indexA) =  Pgen(indexA) - Pload(indexA);
        Qmis(indexA) =  Qgen(indexA) - Qload(indexA);
        for indexB = 1:length(YBus)
            P(indexA) = P(indexA) + V(indexA).*V(indexB).*  real(YBus(indexA,indexB));
            Q(indexA) = Q(indexA)  -   V(indexA).*V(indexB).*  imag(YBus(indexA,indexB));
        end
    end
end

impEQ = nonzeros([Pmis(2:end);(Qmis(2:end).*PQlist(2:end))]);