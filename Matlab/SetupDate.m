%param: mode: when mode = 1, DatePick is supposed to be [strDate_StartTime,
%strDate_StartTime+1, strDate_StartTime + 2,.....,
%strDate_StartTime+consecutiveNum]
%when mode =2, aussuming the day of week of strDate_StartTime is Wednesday,
%then the DatePick is supposed to be [strDate_StartTime,
%strDate_StartTime+7, ...., strDate_StartTime + 7*consecutiveNum] 

function [DatePick, DatesLength] = SetupDate(strDate_StartTime, consecutiveNum, mode)
    DatePick = zeros(consecutiveNum, 1);
    DatesLength = consecutiveNum;
    
    if(consecutiveNum < 1)
        disp('No date selected!');
    end
    
    switch mode
        case 1
            for i = 1 : consecutiveNum
                DatePick(i, 1) = datenum(strDate_StartTime) + 1 * (i - 1);
            end
        case 2
            for i = 1 : consecutiveNum
                DatePick(i, 1) = datenum(strDate_StartTime) + 7 * (i - 1);
            end
        otherwise
            disp('No options available!');
    end
    
    if (DatesLength ~= max(size(DatePick)))
        disp('DatesLength ~= max(size(DatePick))');
    end
    
end
