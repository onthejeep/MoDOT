NET.addAssembly('System.Data');
import System.Data.SqlClient.*;

warning off;



connDB = SqlConnection(['Data Source=128.196.93.131;'...
'Initial Catalog=MoDOTRealtime;'...
'User ID = shu; password = Sql.slu2012']);
connDB.Open();


varType = 'speed';
Mode = 1;
NumDays = 2;
[TimeSpan, TimeSpan_Length] = SetupDate('2013-08-22', NumDays, Mode); %2013-08-22
peakStart = 12;
peakEnd = 19;
aggregationLevel = 5;

% links = [35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2]; %

% Compton Ave Overpass (MI064W038.3U) ~  WO S Hanley Rd (MI064W032.0U)@@SO Galleria Pkwy (MI170N000.3U) ~ Woodson Rd Underpass (MI170N003.8U)
 links = [295, 296, 297, 298, 299, 300, 301, 302, 303];


% Compton Ave Overpass (MI064W038.3U) ~  
% WO S Hanley Rd (MI064W032.0U)@@SO% Galleria Pkwy (MI170N000.3U) ~ 
% NO Natural Bridge Rd(MI170N007.2U)@@McDonnell Blvd (MI070W238.2D) ~ 
% I-170 (MI070W238.6D)
%links = [33, 32, 31, 30, 29,  45, 36, 37, 38, 39, 40, 41, 95, 78, 77, 76];

links = transpose(links);

[ isConnectivity ] = CheckConnectivity( links);
if(isConnectivity == false)
    return;
end
    

[ detectorIDs, locationSpeedData ] = Links2Locations( links, TimeSpan, peakStart, peakEnd, aggregationLevel, connDB );

[ LinkLengths, CorridorTT ] = CorridorTraveltime( locationSpeedData, detectorIDs, connDB );

CheckDataQuality( locationSpeedData, TimeSpan, peakStart, peakEnd, aggregationLevel );


DrawTraveltime(cell2mat(CorridorTT(:, 2)), peakStart, peakEnd);

disp(sum(LinkLengths));

connDB.Close();