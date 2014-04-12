NET.addAssembly('System.Data');
import System.Data.SqlClient.*;

warning off;

connDB = SqlConnection(['Data Source=128.196.93.131;'...
'Initial Catalog=MoDOTRealtime;'...
'User ID = shu; password = Sql.slu2012']);
connDB.Open();


varType = 'speed';
Mode = 1;
NumDays = 3;
[TimeSpan, TimeSpan_Length] = SetupDate('2013-09-24', NumDays, Mode);
peakStart = 6;
peakEnd = 20;

aggregationLevel = 5;

CheckDataQuality( LocationSpeedData, TimeSpan, peakStart, peakEnd, aggregationLevel );