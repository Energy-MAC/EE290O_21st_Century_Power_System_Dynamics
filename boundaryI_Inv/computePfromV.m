function [P_AC,Q_AC] = computePfromV(V,Y)
            % Input: vphasorVec, admittance matrix Y
            % Output: net nodal P and Q at each node
            % Use AC pow flow eqns to compute powers from voltages
            % NOTE: this assumes all nodes are load PQ nodes (V and angle
            % known, P&Q unknown)
            N=size(Y,1); % number of nodes
            numKnown=1; % slackbus
                G = real(Y); B = imag(Y);
            start = numKnown+1; % initalize as symbolic expression

                for i=start:N
                    P(i) = 0;
                    for n=1:N
                        sumPiece = abs(V(i))*abs(V(n))*(G(i,n)*cos(angle(V(i))-angle(V(n)))+B(i,n)*sin(angle(V(i))-angle(V(n))));
                        P(i)=P(i)+sumPiece;
                    end
                end

                for i=start:N
                    Q(i) = 0;
                    for n=1:N
                        sumPiece = abs(V(i))*abs(V(n))*(G(i,n)*sin(angle(V(i))-angle(V(n)))-B(i,n)*cos(angle(V(i))-angle(V(n))));
                        Q(i) = Q(i)+sumPiece;
                    end
                end
            P_AC=-P.'; % negative to agree with sign convention
            Q_AC=-Q.';
end

