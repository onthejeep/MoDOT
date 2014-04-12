%author: Shu Yang (Smart Transportation Lab @UA)
%modifed date: 2013-12-19

function [] = MainEntry(txtConsecutiveDays, txtMode, txtStartTime, txtStartHour, txtEndHour, chain)

%clear all;
%close all;

%========================Basic Options================================
strDate_StartTime = txtStartTime;%2013-02-21
consecutiveDays = txtConsecutiveDays;
peakStart = txtStartHour;% Military time
peakEnd = txtEndHour;% Military time

%======================Advanced Options===============================
Mode = txtMode;% Options: 1 - consecutive days; 2 - every Monday/Tues/Wed...
%VarType = 'speed';% Options (case-insensitive): speed/ volume/ occupancy
AggregationLevel = 5;% Any positive integer


%=========================Input Pre-Process============================

[TimeSpan, TimeSpan_Length] = SetupDate(strDate_StartTime, consecutiveDays, Mode); %2013-08-22

NET.addAssembly('System.Data');
import System.Data.SqlClient.*;

warning off;

connDB = SqlConnection(['Data Source=128.196.93.142;'...
'Initial Catalog=MoDOTRealtime;'...
'User ID = shu; password = Sql.slu2012']);
connDB.Open();


[ isConnectivity ] = CheckConnectivity( chain);
if(isConnectivity == false)
    return;
end
    

[ detectorIDs, locationSpeedData ] = Links2Locations( chain, TimeSpan, peakStart, peakEnd, AggregationLevel, connDB );

CheckDataQuality( locationSpeedData, TimeSpan, peakStart, peakEnd, AggregationLevel );


[ LinkLengths, CorridorTT ] = CorridorTraveltime( locationSpeedData, detectorIDs, connDB );
DrawTraveltime(cell2mat(CorridorTT(:, 2)), peakStart, peakEnd, [0 0 1]);


[ SpeedMatrix, TimeVector, LocationVector ] = SpeedMapData( locationSpeedData, detectorIDs );
Draw3DSpeedMap(TimeVector, LocationVector,  SpeedMatrix, detectorIDs, peakStart, peakEnd, TimeSpan, Mode);

disp(sum(LinkLengths));

connDB.Close();


end

