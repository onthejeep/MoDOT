%param: links = [35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22,
%21, 20, 19, 18, 17, 16, 15, 14, 13, 12]T
%param: locations = DetectorID

function [ detectorIDs, LocationSpeedData ] = Links2Locations( chain, timeSpan, peakStart, peakEnd, aggregationLevel, connDB )
    
    load('Preload\\Links.mat');
    load('Preload\\Nodes.mat');
    
    NumLinks = length(chain);
    NumLocations = NumLinks + 1;
    
    detectorIDs = cell(NumLocations, 1);
    
    LocationSpeedData = cell(NumLocations, 1);
    
fprintf('<a href="">Starting to retrieve the data from remote database.....</a>\n');

    for i = 1: NumLinks

        detectorIDs{i, 1} = Links{chain(i,1), 2};
        LaneNumber = Nodes(detectorIDs{i, 1}).LaneNumber;
        
        LocationSpeedData{i, 1} = RetrieveRealtimedata_OneLocation_MultipleDays( detectorIDs{i, 1}, LaneNumber, 'speed', timeSpan, peakStart, peakEnd, aggregationLevel, connDB );  
    end
    
    detectorIDs{NumLocations, 1} = Links{chain(NumLinks,1), 3};
    LaneNumber = Nodes(detectorIDs{NumLocations, 1}).LaneNumber;
    LocationSpeedData{NumLocations, 1} = RetrieveRealtimedata_OneLocation_MultipleDays( detectorIDs{NumLocations, 1}, LaneNumber, 'speed', timeSpan, peakStart, peakEnd, aggregationLevel, connDB );  
    
    save('Results\\LocationSpeedData.mat', 'LocationSpeedData');
    
fprintf('<a href="">Retrieving the data from remote database is completed......</a>');

fprintf('\n\n');

end

