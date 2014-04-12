%param: varType: speed, volume, occupancy
%goal: get the data from 
% 1: one specific location
% 2: one day from X to Y
% 3. raw speed data from lanes

function [TimeSerie, LaneVariable] = RetrieveRealtimedata_basic(charDetectorID, intLaneNumber, varType, strDate, peakStart, peakEnd, connDB)
    import System.Data.SqlClient.*;
    
    % get the month info
    DateNum = datenum(strDate);
    DateVec = datevec(DateNum);
    Month = DateVec(:,2);
    Year = DateVec(:,1);
    strMonth = '';
    
    strDate_StartTime = sprintf('%s %d:00:00', strDate, peakStart);
    
    if(peakEnd ~= 24)
        strDate_EndTime = sprintf('%s %d:00:00', strDate, peakEnd);
    else
        strDate_EndTime = sprintf('%s 23:59:59', strDate);
    end
    
    if(Month >= 10)
        strMonth = sprintf('%d', Month);
    else
        strMonth = sprintf('0%d', Month);
    end

    sql_select_command = sprintf(['SELECT * '...
    'FROM [%d_%s_%sLane] '...
    'where DetectorID = ''%s'' and (Date_Time between ''%s'' and ''%s'')  ' ...
    'order by [Date_Time]'], Year, strMonth, num2str(intLaneNumber), charDetectorID, strDate_StartTime, strDate_EndTime);%'and datepart(hour, Date_Time) between %d and %d '...

fprintf('\t%s\n', sql_select_command);

    TimeSerie = zeros(0,1);
    
    %LaneVariable can be "speed", "volume" or "occupancy"
    LaneVariable = zeros(0,intLaneNumber);

    q = SqlCommand(sql_select_command, connDB);
    q.CommandTimeout = 90;

    r = q.ExecuteReader();

    i = 1;
    
    VarType_DefaultValue = 60;
    
    %the default value of ColumnIndex is 5, which means the speed data will
    %be retrieved
    ColumnIndex = 5;
    
    if (strcmpi(varType, 'speed'))
        ColumnIndex = 5;
    elseif (strcmpi(varType, 'volume'))
        ColumnIndex = 3;
        VarType_DefaultValue = 0;
    elseif  (strcmpi(varType, 'occupancy'))
        ColumnIndex = 4;
    else
        ColumnIndex = 5;
    end

    while r.Read()
        TimeSerie(i,1) = datenum(char(r.GetDateTime(0).ToString()));

        for n = 1: intLaneNumber  
            Temp1 = double(char(r.GetValue(2 + ColumnIndex + 5 * (n-1))));
            
            if (Temp1 == -1.0 ||Temp1 == 0.0)
                LaneVariable(i, n) = VarType_DefaultValue;
            else
                LaneVariable(i, n) = Temp1;
                VarType_DefaultValue = Temp1;
            end
            
        end

        i = i + 1;
    end

    r.Close();


end


