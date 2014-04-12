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
[TimeSpan, TimeSpan_Length] = SetupDate('2013-09-06', NumDays, Mode);
peakStart = 12;
peakEnd = 19;

charDetectorID = 'MI064W032.0U';
intLaneNumber = 3;
[ FromLocationDetector ] = RetrieveRealtimedata_OneLocation_MultipleDays( charDetectorID, intLaneNumber, varType, TimeSpan, peakStart, peakEnd, connDB );


charDetectorID = 'MI170N000.3U';
intLaneNumber = 2;
[ ToLocationDetector ] = RetrieveRealtimedata_OneLocation_MultipleDays( charDetectorID, intLaneNumber, varType, TimeSpan, peakStart, peakEnd, connDB );

LinkLength = 0.58;

[ LinkTraveltime ] = LinkTravelTime( LinkLength, FromLocationDetector, ToLocationDetector, 'Turning', 1.1);

save('LinkTraveltime.mat', 'LinkTraveltime');
    
connDB.Close();