function [] = DrawTraveltime(CorridorTT, peakStart, peakEnd, LineColor)
    
    %TraveltimeMap = figure;
    
    plot(CorridorTT,'DisplayName','TravelTime','YDataSource','TravelTime', 'Color', LineColor);    
    
    %title(sprintf('Travel Time Profile \n (%s -- %s)', Detectors{detectorIndex,1}.ID, Detectors{detectorIndex + consecutive - 1,1}.ID), 'fontsize', 20);
    title(sprintf('Travel Time Profile'), 'fontsize', 20);
    xlabel('Time of Day', 'fontsize', 20);
    ylabel('TravelTime (minutes)', 'fontsize', 20);
    
    Interval = (peakEnd - peakStart) + 1;
    xTick = linspace(1, length(CorridorTT), Interval);
    xTickLabel = cell(0,1);
    
    Hour = peakStart;
    Minute = 0;
    
    for i = 1: Interval
        xTickLabel{i,1} = sprintf('%02d', Hour);
        Hour = Hour + 1;
%         Minute = Minute + 30;
%         if(Minute == 60)
%             Hour = Hour + 1;
%             Minute = 0;
%         end
    end
    
    set(gca,'Xtick', xTick, 'XTickLabel', xTickLabel);
%     set(gca,'Ytick', yTick, 'YTickLabel', yTickLabel);
end