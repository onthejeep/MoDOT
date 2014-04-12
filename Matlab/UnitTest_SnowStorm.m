%author: Shu Yang (Smart Transportation Lab @UA)
%modifed date: 2013-12-19

function [] = UnitTest_SnowStorm()
    
NET.addAssembly('System.Data');
import System.Data.SqlClient.*;

warning off;

    connDB = SqlConnection(['Data Source=128.196.93.142;'...
    'Initial Catalog=MoDOTRealtime;'...
    'User ID = shu; password = Sql.slu2012']);
    connDB.Open();


    StartDate = '2014-01-09';
    EndDate = '2014-01-09';

    peakStart = 0;% Military time
    peakEnd = 24;% Military time
    
    Links2Locations_Volume( StartDate, EndDate, peakStart, peakEnd, connDB );
    
    connDB.Close();

end

function [] = Snow_Volume(txtStartTime, peakStart, peakEnd, referencePoint, lineColor, connDB)
    %========================Basic Options================================
    strDate_StartTime = txtStartTime;%2013-02-21

    %======================Advanced Options===============================
    AggregationLevel = 15;% Any positive integer
    
    %=========================Input Pre-Process============================
    [ AggregationTable_Volume ] = Links2Locations_Volume( referencePoint, strDate_StartTime, peakStart, peakEnd, AggregationLevel, connDB );
    DrawVolume_ReferencePoint(AggregationTable_Volume, peakStart, peakEnd, lineColor);
    
    DailyVolume = sum(cell2mat(AggregationTable_Volume(:, 3)));
    
    fprintf('        [ Date: %s] Hourly Volume is : %0.0f (veh) \n', strDate_StartTime, DailyVolume / (peakEnd - peakStart) );
    
    hold on;
end

function [] = SnowStorm_Traveltime(txtStartTime, peakStart, peakEnd, StartDetector, EndDetector, LineColor, connDB)

    %========================Basic Options================================
    strDate_StartTime = txtStartTime;%2013-02-21
    consecutiveDays = 1;

    %======================Advanced Options===============================
    Mode = 1;% Options: 1 - consecutive days; 2 - every Monday/Tues/Wed...
    AggregationLevel = 15;% Any positive integer


    %=========================Input Pre-Process============================

    [TimeSpan, TimeSpan_Length] = SetupDate(strDate_StartTime, consecutiveDays, Mode); %2013-08-22

    [ Chain ] = GUI_Translate2Links( StartDetector, EndDetector );

    [ isConnectivity ] = CheckConnectivity( Chain);
    if(isConnectivity == false)
        return;
    end


    [ detectorIDs, locationSpeedData ] = Links2Locations( Chain, TimeSpan, peakStart, peakEnd, AggregationLevel, connDB );
    CheckDataQuality( locationSpeedData, TimeSpan, peakStart, peakEnd, AggregationLevel );


    [ LinkLengths, CorridorTT ] = CorridorTraveltime( locationSpeedData, detectorIDs, connDB );
    DrawTraveltime(cell2mat(CorridorTT(:, 2)), peakStart, peakEnd, LineColor);
    hold on;


    % [ SpeedMatrix, TimeVector, LocationVector ] = SpeedMapData( locationSpeedData, detectorIDs );
    % Draw3DSpeedMap(TimeVector, LocationVector,  SpeedMatrix, detectorIDs, peakStart, peakEnd, TimeSpan, Mode);
    % 
    % disp(sum(LinkLengths));

end




