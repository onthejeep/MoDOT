
NET.addAssembly('System.Data');
import System.Data.SqlClient.*;

warning off;

connDB = SqlConnection(['Data Source=128.196.93.131;'...
'Initial Catalog=MoDOTRealtime;'...
'User ID = shu; password = Sql.slu2012']);
connDB.Open();


charDetectorID = 'MI064W035.7U';
intLaneNumber = 4;
varType = 'speed';
Mode = 1;

[TimeSpan, TimeSpan_Length] = SetupDate('2013-08-21', 2, Mode);
peakStart = 12;
peakEnd = 19;

[ LocationDetector ] = RetrieveRealtimedata_OneLocation_MultipleDays( charDetectorID, intLaneNumber, varType, TimeSpan, peakStart, peakEnd, connDB );
    
connDB.Close();