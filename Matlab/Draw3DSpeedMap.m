%Prototype: Draw3DSpeedMap(detectorIndex, consecutive, x_Time, y_Detector, z_Speed, I64Detectors)
%param: detectorIndex: the starting detector
%param: n: # of the consecutive detectors required
%param: I64Detectors: detectors info
%param: x_Time
%param: y_Detector
%param: z_Speed
function Draw3DSpeedMap(timeVector, locationVector,  speedMatrix, detectorIDs, peakStart, peakEnd, TimeSpan, Mode)

    load('Preload\\Nodes.mat'); %param: 'Nodes'
    
    locationVector_New = min(locationVector):0.05:max(locationVector); 
    locationVector_New = locationVector_New';
    
    NumLocations = size(locationVector, 2);
    
    SpeedMap_3D = figure;
    
    SpeedMatrix_New = interp2(timeVector, locationVector, speedMatrix, timeVector, locationVector_New, 'spline');

    axes1 = axes('Parent',SpeedMap_3D);
    hold(axes1,'all');
    
    surf(SpeedMatrix_New, 'EdgeColor', 'none');
    
    c= [     
    1.0000         0         0
    1.0000    0.0469         0
    1.0000    0.0938         0
    1.0000    0.1406         0
    1.0000    0.1875         0
    1.0000    0.2344         0
    1.0000    0.2813         0
    1.0000    0.3281         0
    1.0000    0.3750         0
    1.0000    0.4219         0
    1.0000    0.4688         0
    1.0000    0.5156         0
    1.0000    0.5625         0
    1.0000    0.6094         0
    1.0000    0.6563         0
    1.0000    0.7031         0
    1.0000    0.7500         0
    1.0000    0.7969         0
    1.0000    0.8438         0
    1.0000    0.8906         0
    1.0000    0.9375         0
    1.0000    0.9844         0
    0.9688    1.0000         0
    0.9219    1.0000         0
    0.8750    1.0000         0
    0.8281    1.0000         0
    0.7813    1.0000         0
    0.7344    1.0000         0
    0.6875    1.0000         0
    0.6406    1.0000         0
    0.5938    1.0000         0
    0.5469    1.0000         0
    0.5000    1.0000         0
    0.4531    1.0000         0
    0.4063    1.0000         0
    0.3594    1.0000         0
    0.3125    1.0000         0
    0.2656    1.0000         0
    0.2188    1.0000         0
    0.1719    1.0000         0
    0.1250    1.0000         0
    0.0781    1.0000         0
    0.0313    1.0000         0];

    set(gcf, 'renderer', 'zbuffer');
    
    colormap(c);
    caxis([35 75]);
    colorbar;
    
    switch Mode
        case 1
            strSubTitle = sprintf('\\fontsize{10}From %s  To %s, continuous day', datestr(TimeSpan(1,1)), datestr(TimeSpan(end, 1)));
        case 2
             [dayofweekN, dayofweekS] = weekday(datestr(TimeSpan(1,1)), 'long');
            strSubTitle = sprintf('\\fontsize{10}From %s  To %s, each %s', datestr(TimeSpan(1,1)), datestr(TimeSpan(end, 1)), dayofweekS);
            
    end

    title({'\fontsize{30}Speed Heat Map', strSubTitle});
    xlabel('Time of Day', 'fontsize', 20);
    ylabel('DetectorID', 'fontsize', 20);
    
    Interval = (peakEnd - peakStart) + 1;
    
    xTick = linspace(1, max(size(timeVector)), Interval);
    yTick = linspace(1, max(size(locationVector_New)), NumLocations);
    xTickLabel = cell(0,1);
    yTickLabel = cell(0,1);
    
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
    
    for i = 1: NumLocations
        yTickLabel{i,1} = Nodes(detectorIDs{i, 1}).CrossStreet_Short;%Detectors{detectorIndex + i - 1, 1}
    end
    
    set(gca,'Xtick', xTick, 'XTickLabel', xTickLabel);
    set(gca,'Ytick', yTick, 'YTickLabel', yTickLabel);

    view([0,0,90]);
end