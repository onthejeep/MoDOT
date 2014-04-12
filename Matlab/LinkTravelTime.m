function [ LinkTraveltime ] = LinkTravelTime( linkLength, speed_from, speed_to, linkType, factor)
    
    TimeLength = length(speed_from{end, 1}.AggregationData);
    
    LinkTraveltime = zeros(TimeLength - 1, 1);
    
    for i = 1: TimeLength - 1
        
        if strcmpi(linkType, 'Link')
            LinkTraveltime(i, 1) = linkLength * 2 / ( speed_from{end, 1}.AggregationData{i, 4} + speed_to{end, 1}.AggregationData{i, 4}) * 60 * factor; % unit: minute
        else% Turning
            LinkTraveltime(i, 1) = linkLength * 2 / ( speed_from{end, 1}.AggregationData{i, 6} + speed_to{end, 1}.AggregationData{i, 6}) * 60 * factor; % unit: minute
        end
        
    end

end

