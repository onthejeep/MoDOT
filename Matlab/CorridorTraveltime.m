function [ LinkLengths, CorridorTT ] = CorridorTraveltime( locationSpeedData, detectorIDs, connDB )
    load('Preload\\Nodes.mat');
    load('Preload\\Links.mat');
    import System.Data.SqlClient.*;
    
    NumLocation = length(locationSpeedData);
    NumDays = length(locationSpeedData{1, 1});
    
    NumTimeInterval = length(locationSpeedData{1, 1}{NumDays, 1}.AggregationData) - 1; % the last row in 'locationSpeedData' is non
    
%     TimeVector = zeros(1, NumTimeInterval);
%     
%     for i = 1: NumTimeInterval     
%         TimeVector(1, i) = locationSpeedData{1, 1}{NumDays, 1}.AggregationData{i, 1};
%     end


    LinkLengths = zeros(NumLocation - 1, 1);
    
    CorridorTT = cell(NumTimeInterval, 2);
    for i = NumTimeInterval
        CorridorTT{i, 1} = [];
        CorridorTT{i, 2} = 0;
    end
    
    for i = 1: NumLocation - 1
        
        From_DetectorID = detectorIDs{i, 1};
        To_DetectorID = detectorIDs{i + 1, 1};
        
        for m = 1: length(Nodes(From_DetectorID).NextLink)
            if(strcmp(Nodes(From_DetectorID).NextNode{m, 1}, To_DetectorID))
                break;
            end
        end
        
        LinkID = Nodes(From_DetectorID).NextLink(m,1);
        
        LinkLength = Links{LinkID, 4};
        LinkLengths(i, 1) = LinkLength;
        LinkType = Links{LinkID, 5};
        Factor = Links{LinkID, 6};
        
        LinkTT = LinkTravelTime( LinkLength, locationSpeedData{i, 1}, locationSpeedData{i + 1, 1}, LinkType, Factor);
        
        for j = 1: NumTimeInterval
            CorridorTT{j, 1} = [CorridorTT{j, 1}, LinkTT(j, 1)];
        end
    end
    
    for i = 1: NumTimeInterval
        CorridorTT{i, 2} = sum(CorridorTT{i, 1});
    end
    
    save('Results\\CorridorTT.mat', 'CorridorTT');

end