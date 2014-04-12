function [ isConnectivity ] = CheckConnectivity( chain)

    fprintf('<a href="">Starting to check the connectivity of the links...... </a>\n');
    fprintf('<a href="">Result:\n</a>');
    
    load('Preload\\Links.mat');
    
    ChainLength = length(chain);
   
    for i = 1: ChainLength - 1
        
        if strcmp(Links{chain(i, 1), 3}, Links{chain(i + 1, 1), 2})
        else
            isConnectivity = false;
            fprintf('\tThe links are NOT connected!\n');
            fprintf('<a href="">Checking the connectivity of the links is completed......</a>');
            fprintf('\n\n');
            return;
        end
    end
    
    isConnectivity = true;
    fprintf('\tThe links are connected!\n');
    fprintf('<a href="">Checking the connectivity of the links is completed......</a>');
    fprintf('\n\n');
end

