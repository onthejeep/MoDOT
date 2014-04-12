NET.addAssembly('System.Data');
import System.Data.SqlClient.*;

warning off;

connDB = SqlConnection(['Data Source=128.196.93.131;'...
'Initial Catalog=MoDOTRealtime;'...
'User ID = shu; password = Sql.slu2012']);
connDB.Open();


varType = 'speed';
Mode = 1;
NumDays = 1;
[TimeSpan, TimeSpan_Length] = SetupDate('2012-09-11', NumDays, Mode);
peakStart = 12;
peakEnd = 19;
aggregationLevel = 5;

disp(TimeSpan);

links = [295, 296, 297, 298, 299, 300, 301, 302, 303];

links = transpose(links);

[ detectorIDs, locationSpeedData ] = Links2Locations( links, TimeSpan, peakStart, peakEnd, aggregationLevel, connDB );

[ SpeedMatrix, TimeVector, LocationVector ] = SpeedMapData( locationSpeedData, detectorIDs );


Draw3DSpeedMap(TimeVector, LocationVector,  SpeedMatrix, detectorIDs, peakStart, peakEnd, TimeSpan, Mode);

connDB.Close();