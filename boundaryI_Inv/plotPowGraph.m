% create spatial graph of power network with nodes labeled and markesizes
% proportional to apparent power at each node. Color inverter bus with red
% marker
% called by solvePF_compare
function [] = plotPowGraphplotGraph(G,knowns,titleStr,invBus)
    N=size(G.Nodes,1);
    figure; h=plot(G);title(titleStr);
    nodeWeights=sqrt(knowns(:,3).^2+knowns(:,4).^2); 
    nodeLabels=num2str(round(knowns(:,3),2)+j*round(knowns(:,4),2));    
    labelnode(h,1:N,cellstr(nodeLabels));
    highlight(h,invBus,'NodeColor','r')
    maxMarkerSize=20; % to normalize weights
    a=max(nodeWeights); % to normalize weights
    nodeWeights(find(nodeWeights<=0))=0.1; % width cannot be <=0, so set as 0.1
    for i=1:N
        highlight(h,i,'MarkerSize',nodeWeights(i)*(maxMarkerSize/a))
    end
end

