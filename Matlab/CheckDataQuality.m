function [ ] = CheckDataQuality( locationSpeedData, timeSpan, peakStart, peakEnd, aggregationLevel )

    NumLocation = length(locationSpeedData);
    NumDays = length(locationSpeedData{1, 1}) - 1;
    
    NumTimeInterval = length(locationSpeedData{1, 1}{end, 1}.AggregationData);
    
    % Considering without data missing, the number of data samples is
    % supposed to be (Hours * 120); TWO files within 1
    % minute, 120 samples within an hour
    NormalSampleSize_Total = (peakEnd - peakStart) * 2 * 1 * 60;
    NormalSampleSize_AggregationLevel = 2 * aggregationLevel;

    fprintf('<a href="">Starting to check the data quality......</a>\n');
    fprintf('<a href="">Results:</a>\n');
    
    
    DataSummary = cell(NumDays, 1);
    
    Output2Txt = cell(NumTimeInterval - 1, 2 * length(timeSpan));
    
    %different traffic sensors have the same missing rate, only check one
    %sensor
    SampleSizeMatrix = cell2mat(locationSpeedData{1, 1}{end, 1}.AggregationData(:, 3));
    
    for i = 1: length(DataSummary)
        
        DateVector = datevec(timeSpan(i));
        Year = DateVector(:, 1);
        Month = DateVector(:, 2);
        Date = DateVector(:, 3);
        
        EachDay.DateString = sprintf('%4d-%02d-%02d', Year, Month, Date);
        EachDay.FromHour = peakStart;
        EachDay.ToHour = peakEnd;
        EachDay.NormalSampleSize = NormalSampleSize_Total;
        EachDay.SampleSize = sum(SampleSizeMatrix(:,i));
        EachDay.Rate = EachDay.SampleSize / EachDay.NormalSampleSize;
        
        for j = 1: NumTimeInterval - 1
            
            HourMinuteVector = datevec(locationSpeedData{1, 1}{end, 1}.AggregationData{j, 1});            
            
            Output2Txt{j, i * 2 -1} = sprintf('%s %02d:%02d', EachDay.DateString, HourMinuteVector(:, 4), HourMinuteVector(:, 5));
            Output2Txt{j, i * 2} = sprintf('%6.3f %%', (1 - SampleSizeMatrix(j, i) / NormalSampleSize_AggregationLevel) * 100);
        end
        
        fprintf('\t [Time Period] %s from %02d to %02d [Data Missing Rate] %0.2f %%\n', EachDay.DateString, EachDay.FromHour, EachDay.ToHour, (1- EachDay.Rate) * 100);
    
    end
    
    fprintf('<a href="Results\\DataQuality.txt">Checking the data quality is completed...... More information can be found here......</a>\n\n');
    
    FileID = fopen('Results\\DataQuality.txt', 'w');
    fprintf(FileID, '%s\n', 'Pairs ( Date & Time        Missing Rate )');
    for i =1: length(Output2Txt)
        fprintf(FileID, '%s\t', Output2Txt{i,:});
        fprintf(FileID, '\n');
    end
    
    fclose(FileID);

end

