function [ SpeedMatrix, TimeVector, LocationVector ] = SpeedMapData( locationSpeedData, detectorIDs )
    
    load('Preload\\Nodes.mat');%param: 'Nodes'
    
    NumLocation = length(locationSpeedData);
    NumDays = length(locationSpeedData{1, 1});
    
    NumTimeInterval = length(locationSpeedData{1, 1}{NumDays, 1}.AggregationData);
    
    SpeedMatrix = zeros(NumLocation, NumTimeInterval);% SpeedData
    TimeVector = zeros(1, NumTimeInterval);
    
    LocationVector = linspace(0, NumLocation-1, NumLocation);
    
    for i = 1: NumTimeInterval     
        TimeVector(1, i) = locationSpeedData{1, 1}{NumDays, 1}.AggregationData{i, 1};
    end
    
    for i = 1: NumLocation - 1
        for j = 1: NumTimeInterval
            
            if strcmpi(Nodes(detectorIDs{i, 1}).StreetName, Nodes(detectorIDs{i + 1, 1}).StreetName) % type = 'link' 
                SpeedMatrix(i, j) = locationSpeedData{i, 1}{NumDays, 1}.AggregationData{j, 4};
            else% type = 'turning'
                SpeedMatrix(i, j) = locationSpeedData{i, 1}{NumDays, 1}.AggregationData{j, 6};
            end
            
        end
    end
    
    % The last location/node
    for j = 1: NumTimeInterval
        if strcmpi(Nodes(detectorIDs{NumLocation - 1, 1}).StreetName, Nodes(detectorIDs{NumLocation, 1}).StreetName) % type = 'link'
            SpeedMatrix(NumLocation, j) = locationSpeedData{NumLocation, 1}{NumDays, 1}.AggregationData{j, 4};
        else% type = 'turning'
            SpeedMatrix(NumLocation, j) = locationSpeedData{NumLocation, 1}{NumDays, 1}.AggregationData{j, 6};
        end
    end
    
    
    save('Results\\SpeedMatrix.mat', 'SpeedMatrix');
end
