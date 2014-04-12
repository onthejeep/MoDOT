function [  ] = DrawVolume_ReferencePoint(AggregationTable_Volume, peakStart, peakEnd, LineColor)

    plot(cell2mat(AggregationTable_Volume(:, 3)), 'Color', LineColor);    
    
    title(sprintf('Traffic Volume Profile'), 'fontsize', 20);
    xlabel('Time of Day', 'fontsize', 20);
    ylabel('Volume (veh)', 'fontsize', 20);
    
    Interval = (peakEnd - peakStart) + 1;
    xTick = linspace(1, length(AggregationTable_Volume), Interval);
    xTickLabel = cell(0,1);
    
    Hour = peakStart;
    
    for i = 1: Interval
        xTickLabel{i,1} = sprintf('%02d', Hour);
        Hour = Hour + 1;
    end
    
    set(gca,'Xtick', xTick, 'XTickLabel', xTickLabel);

end

