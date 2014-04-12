function [ chain ] = GUI_Translate2Links( startNode, endNode )
    load('Preload\\Nodes.mat');


    if strcmp(startNode, endNode)
        chain = zeros(0,0); % it is empty   
        return;
    end
    
    chain = zeros(0,1);
    i = 1;
    
    startNodeCopy = startNode;
    endNodeCopy = endNode;
    
    % the direction cannot be identified from the detector IDs, so try both
    % way
    while ~strcmp(startNodeCopy, endNodeCopy)
        if strcmp(startNodeCopy, 'End')
            chain = zeros(0,1); % reset
            i = 1;
            break;
        else
            chain(i, 1) = Nodes(startNodeCopy).NextLink(1,1); % there may be several NextLinks and NextNodes, NextLink(1,1) and NextNode(1,1) are always on the same freeway
            i = i + 1;
            
            startNodeCopy = Nodes(startNodeCopy).NextNode{1,1};
        end
    end
    
    if(~isempty(chain))
        return;
    end
    
    
    while ~strcmp(endNode, startNode)
        if strcmp(endNode, 'End')
            chain = zeros(0,1); % reset
            break;
        else
            chain(i, 1) = Nodes(endNode).NextLink(1,1); % there may be several NextLinks and NextNodes, NextLink(1,1) and NextNode(1,1) are always on the same freeway
            i = i + 1;
            
            endNode = Nodes(endNode).NextNode{1,1};
        end
    end
    
end