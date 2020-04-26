function myH=myPTDF(network,refBus)
% input: power network Y, bus i
% output: power distribution factors (PDF)

% PDFs tells us how line flows change in response to a power injection at a
% given bus; for example the power injection could be from
% addition/deletion of a generator

c=network;  
nbr=size(c.branch,1);
    nb=size(c.bus,1);

    % Create PTDF
    [Bbus Bf Pbusinj Pfinj]=makeBdc(c);
  %  slackidx=refBus % default assignment if slack not specified
    slackidx=find(c.bus(:,2)==1);
    Bf=full(Bf);
    Bfsq=Bf(:,[1:refBus-1,refBus+1:size(Bf,2)]); % delete ref bus col
    temp=Bbus(:,[1:refBus-1,refBus+1:size(Bbus,2)]); % delete ref bus col
    Bdc=temp([1:slackidx-1,slackidx+1:size(temp,1)],:); % delete slack bus row
    Hksq=Bfsq*inv(Bdc);
    k=slackidx;
    Hk=[Hksq(:,1:k-1) zeros(nbr,1) Hksq(:,k:end)]; % add col of zeros at col k

    myH=full(Hk); % convert from sparse to regular matrix
end

