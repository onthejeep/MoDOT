%param: links = [35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22,
%21, 20, 19, 18, 17, 16, 15, 14, 13, 12]T
%param: locations = DetectorID

function [  ] = Links2Locations_Volume( StartDate, EndDate, peakStart, peakEnd, connDB )
    
    load('Preload\\Nodes.mat');
    
    load('PreLoad\\I170S.mat');
    
    TimeSpan = datenum(StartDate): 1: datenum(EndDate);
    
    Summary = cell(length(I170S), 2);
  
    for referencePoint = 1: length(I170S)
        LaneNumber = Nodes(I170S{referencePoint, 1}).LaneNumber;

        [ OnePointVolume ] = ReferencePointVolume( I170S{referencePoint, 1}, LaneNumber, TimeSpan, peakStart, peakEnd, connDB );
        
        save(sprintf('%s.mat', I170S{referencePoint, 1} ), 'OnePointVolume');
        
        Summary{referencePoint, 1} = I170S{referencePoint, 1};
        Summary{referencePoint, 2} = mean(OnePointVolume);
    end
    
    save('Summary.mat', 'Summary');
    
end


function [ OnePointVolume ] = ReferencePointVolume( referencePoint, LaneNumber, TimeSpan, peakStart, peakEnd, connDB )
    
    OnePointVolume = zeros(length(TimeSpan), 1);
    
    for date = 1: length(TimeSpan)
        StrDate = datestr(TimeSpan(date));
        
        [TimeSerie, LaneVariable] = RetrieveRealtimedata_basic(referencePoint, LaneNumber, 'volume', StrDate, peakStart, peakEnd, connDB);
        TotalVolume = sum(LaneVariable(:));
        
        OnePointVolume(date, 1) = TotalVolume;
    end

end



