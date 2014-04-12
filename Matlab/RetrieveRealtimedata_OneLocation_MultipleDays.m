
function [ LocationSpeedData ] = RetrieveRealtimedata_OneLocation_MultipleDays( charDetectorID, intLaneNumber, varType, timeSpan, peakStart, peakEnd, aggregationLevel, connDB)

    NumDays = length(timeSpan);
    
    LocationSpeedData = cell(NumDays, 1);
    
    for day = 1: NumDays
        
        [TimeSerie, LaneVariable] = RetrieveRealtimedata_basic(charDetectorID, intLaneNumber, varType, datestr(timeSpan(day)), peakStart, peakEnd, connDB);
        
        SingleDay.Time = TimeSerie;
        SingleDay.LaneVariable = LaneVariable;
        
        %----------------------------------------
        [NumLength, NumDim] = size(LaneVariable);
        
        MeanValue = zeros(NumLength, 1);
        MedianValue = zeros(NumLength, 1);
        LeftValue = zeros(NumLength, 1);
        RightValue = zeros(NumLength, 1);
        
        for i = 1:NumLength
            MeanValue(i, 1) = mean(LaneVariable(i, :));
            MedianValue(i, 1) = median(LaneVariable(i, :));
            LeftValue(i, 1) = LaneVariable(i, 1);
            RightValue(i, 1) = LaneVariable(i, NumDim);
        end
        
        SingleDay.Mean = MeanValue;
        SingleDay.Median = MedianValue;
        SingleDay.Left = LeftValue;
        SingleDay.Right = RightValue;
        %----------------------------------------
        
        LocationSpeedData{day, 1}.RawData = SingleDay;
    end
    
    AggregationTable = Aggregation(charDetectorID, LocationSpeedData, aggregationLevel, timeSpan(1), peakStart, peakEnd);
    
    LocationSpeedData{NumDays + 1, 1}.AggregationData = AggregationTable;
    
end

function [AggregationTable] = Aggregation(charDetectorID, locationSpeedData, aggregationLevel, numStartDate, peakStart, peakEnd)
    
    DateStart = floor(numStartDate) + 1/24 * peakStart;
    DateEnd = floor(numStartDate) + 1/24 * peakEnd;
    
    Factor_XMin = aggregationLevel / (24 * 60);
    
    NumBin = (60 / aggregationLevel) * (peakEnd - peakStart) + 1;
    
    NumDays = length(locationSpeedData);
    
    %size = [1 , XXX]
    TimeBin = linspace(DateStart, DateEnd, NumBin);
    
    %AggregationTable = cell{time(hh-mm-ss), array[LaneVariable], sample size, median, array[LaneVariable-RightMost], median}
    AggregationTable = cell(NumBin, 6);
    
    for i = 1: NumBin
        %All Lanes
        AggregationTable{i, 1} = TimeBin(1, i);
        AggregationTable{i, 2} = [];
        AggregationTable{i, 3} = zeros(1, NumDays); %sample size by day
        AggregationTable{i, 4} = 0; %median (AggregationTable{i, 2})
        
        %Right most Lane
        AggregationTable{i, 5} = []; % array[LaneVariable-RightMost]
        AggregationTable{i, 6} = 0; % median (AggregationTable{i, 5})
    end
    
    for day = 1: NumDays
        TimeTable = locationSpeedData{day, 1}.RawData.Time;
        VariableTable = locationSpeedData{day, 1}.RawData.LaneVariable;
        
        for i = 1: length(TimeTable)
            
            value = (    (TimeTable(i, 1) - floor(TimeTable(i, 1)))   -   (DateStart - floor(DateStart))    ) / Factor_XMin;
            
            Bin_Index = floor(value) + 1;

            AggregationTable{Bin_Index, 2} = [AggregationTable{Bin_Index, 2}, VariableTable(i, :)];
            AggregationTable{Bin_Index, 3}(1, day) = AggregationTable{Bin_Index, 3}(1, day) + 1;
            
            AggregationTable{Bin_Index, 5} = [AggregationTable{Bin_Index, 5}, VariableTable(i, 1)];
        end

    end
    
    % Considering without data missing, the number of data samples is
    % supposed to be (NumDays * aggregationLevel * 2); TWO files within 1 minute 
    NormalSampleSize = NumDays * aggregationLevel * 2;
    
    %disp(NormalSampleSize);
    
    for i = 1 : NumBin - 1
        AggregationTable{i, 4} = median(AggregationTable{i, 2});
        AggregationTable{i, 6} = median(AggregationTable{i, 5});
        
        MissingRatio = 1 - sum(AggregationTable{i, 3}) * 1.0 / NormalSampleSize; 
        
        if MissingRatio >= 0.5
            DateNum_From = datenum(AggregationTable{i, 1});
            DateVec_From = datevec(DateNum_From);
            Hour_From = DateVec_From(:,4);
            Minute_From = DateVec_From(:,5);
            
            DateNum_To = DateNum_From + Factor_XMin;
            DateVec_To = datevec(DateNum_To);
            Hour_To = DateVec_To(:,4);
            Minute_To = DateVec_To(:,5);
    
            fprintf('\t\tWARNING: [from %02d:%02d to %02d:%02d; on %s] some data is missing, the results might be less accurate!\n',...
            Hour_From, Minute_From, Hour_To, Minute_To, charDetectorID);
        end
    end
end
















