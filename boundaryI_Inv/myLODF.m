function myL=myLODF(network,refBus)
% input: power network Y, line i
% output: LODFs

% LODFs tell us how line flows change in response to a change in a given line's
% status
c=network ;   
nbr=size(c.branch,1);
    nb=size(c.bus,1);
        Cf=zeros(nbr,nb); Ct=zeros(nbr,nb); % sparse connection matrices
        for i=1:nbr
            j=c.branch(i,1);
            k=c.branch(i,2);
            Cf(i,j)=1;
            Ct(i,k)=1;
        end
        Hk=myPTDF(c,refBus);
        Cnode_br=(Cf-Ct)'; % node-branch incidence matrix, formed by sparse connection matrices
        H=Hk*Cnode_br;
        L=zeros(nbr,nbr); % (num branches)x(num branches)
        for i=1:size(H,1) % rows
            for j=1:size(H,2) % cols
                if i==j
                    L(i,j)=-1;
                else 
                    L(i,j)=H(i,j)/(1-H(j,j));
                end
            end
        end

        myL=full(L); % convert from sparse to regular matrix
end

