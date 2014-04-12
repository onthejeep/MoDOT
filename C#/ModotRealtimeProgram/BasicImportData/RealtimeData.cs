using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.Data.SqlClient;
using System.Data;

using CommonFiles;
using System.IO;

namespace BasicImportData
{
    public class RealtimeData
    {
        private XmlDocument _RealtimeDoc;
        private Realtime_Common _CommonInfo;

        public Realtime_Common CommonInfo
        {
            get { return _CommonInfo; }
        }
        private List<Realtime_Detector> _Detectors;

        public List<Realtime_Detector> Detectors
        {
            get { return _Detectors; }
        }

        private string _Year = "1";
        private string _Month = "-1";

        private SqlCommand[] _InsertCommand;

        public RealtimeData(string fileName)
        {
            _RealtimeDoc = new XmlDocument();
            //_RealtimeDoc.Load(fileName);

            XmlUrlResolver Resolver = new XmlUrlResolver();
            Resolver.Credentials = System.Net.CredentialCache.DefaultCredentials;

            Uri Fulluri = Resolver.ResolveUri(null, fileName);

            Stream S = (Stream)Resolver.GetEntity(Fulluri, null, typeof(Stream));

            _RealtimeDoc.Load(S);

            S.Dispose();

            _CommonInfo = new Realtime_Common();
            _Detectors = new List<Realtime_Detector>(800);

            _InsertCommand = new SqlCommand[6];

            for (int i = 1; i < 7; i++)
            {
                _InsertCommand[i - 1] = new SqlCommand(string.Format("InsertRealtimeData_{0}Lane", i));
                _InsertCommand[i - 1].CommandType = CommandType.StoredProcedure;
                //_InsertCommand[i - 1].Transaction = 

                _InsertCommand[i - 1].Parameters.Add("year", SqlDbType.VarChar, 10);
                _InsertCommand[i - 1].Parameters.Add("month", SqlDbType.VarChar, 10);
                _InsertCommand[i - 1].Parameters.Add("Date_Time", SqlDbType.VarChar, 25);
                _InsertCommand[i - 1].Parameters.Add("Agency", SqlDbType.VarChar, 30);
                _InsertCommand[i - 1].Parameters.Add("DetectorID", SqlDbType.VarChar, 20);

                for (int j = 0; j < i; j++)
                {
                    _InsertCommand[i - 1].Parameters.Add(string.Format("Lane_Number_{0}", j + 1), SqlDbType.Int);
                    _InsertCommand[i - 1].Parameters.Add(string.Format("Lane_Status_{0}", j + 1), SqlDbType.VarChar, 10);
                    _InsertCommand[i - 1].Parameters.Add(string.Format("Lane_Volume_{0}", j + 1), SqlDbType.Float);
                    _InsertCommand[i - 1].Parameters.Add(string.Format("Lane_Occupancy_{0}", j + 1), SqlDbType.Float);
                    _InsertCommand[i - 1].Parameters.Add(string.Format("Lane_Speed_{0}", j + 1), SqlDbType.Float);
                }

                _InsertCommand[i - 1].Parameters.Add("Lane_Volume_Ave", SqlDbType.Float);
                _InsertCommand[i - 1].Parameters.Add("Lane_Occupancy_Ave", SqlDbType.Float);
                _InsertCommand[i - 1].Parameters.Add("Lane_Speed_Ave", SqlDbType.Float);
            }
        }

        public static void CreateNewTable(string year, string month)
        {
            SqlCommand CreateTableCommand = new SqlCommand("CreateRealtimeTable_Reduce");
            CreateTableCommand.CommandType = System.Data.CommandType.StoredProcedure;
            CreateTableCommand.Parameters.Add("year", SqlDbType.VarChar, 10);
            CreateTableCommand.Parameters.Add("month", SqlDbType.VarChar, 10);

            CreateTableCommand.Connection = Connect2DB.GetInisitance();

            CreateTableCommand.Parameters["year"].Value = year;
            CreateTableCommand.Parameters["month"].Value = month;

            try
            {
                CreateTableCommand.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                AlterMailService_Singleton.GetInisitance().Alter.SendMessage("CreateNewTable",  ex.Message);
            }
        }

        private DateTime ParseDatetime(string date, string time)
        {
            int Year = -11, Month = -11, Day = -11, Hour = -11, Minute = -11, Second = -11;

            try
            {
                Year = int.Parse(date.Substring(0, 4));

                _Year = date.Substring(0, 4);
            }
            catch (Exception ex) { };

             try
            {Month = int.Parse(date.Substring(4, 2));
            _Month = date.Substring(4, 2);
            }
            catch (Exception ex) { };
             try
            {Day = int.Parse(date.Substring(6, 2));}
            catch (Exception ex) { };

             try
            {Hour = int.Parse(time.Substring(0, 2));}
            catch (Exception ex) { };
             try
            {Minute = int.Parse(time.Substring(2, 2));}
            catch (Exception ex) { };
             try
             { Second = int.Parse(time.Substring(4, 2)); }
             catch (Exception ex) { };

            DateTime R = new DateTime(1,1,1,1,1,1);

            try
            {R= new DateTime(Year, Month, Day, Hour, Minute, Second);
            }catch (Exception ex) { };

            return R;
        }

        private void Read()
        {
            XmlElement Root = _RealtimeDoc.DocumentElement;

            XmlNodeList DateNode = Root.SelectNodes("date");
            XmlNodeList TimeNode = Root.SelectNodes("time");
            XmlNodeList AgencyNode = Root.SelectNodes("agency");

            _CommonInfo.ReceiveTime = ParseDatetime(DateNode[0].InnerText, TimeNode[0].InnerText);
            _CommonInfo.Agency = AgencyNode[0].InnerText;

            XmlNodeList DetectorList = Root.SelectNodes("detector");

            XmlNodeList DetectorIDNode, LaneNodeList, LaneNumberNode, LaneStatusNode, LaneVolumeNode, LaneOccupancyNode, LaneSpeedNode;

            for (int i = 0; i < DetectorList.Count; i++)
            {
                Realtime_Detector Temp = new Realtime_Detector();

                DetectorIDNode = DetectorList[i].SelectNodes("detector-Id");

                LaneNodeList = DetectorList[i].SelectNodes("lane");

                Temp.DetectorID = DetectorIDNode[0].InnerText;

                for (int j = 0; j < LaneNodeList.Count; j++)
                {
                    LaneNumberNode = LaneNodeList[j].SelectNodes("lane-Number");
                    LaneStatusNode = LaneNodeList[j].SelectNodes("lane-Status");
                    LaneVolumeNode = LaneNodeList[j].SelectNodes("lane-Volume");
                    LaneOccupancyNode = LaneNodeList[j].SelectNodes("lane-Occupancy");
                    LaneSpeedNode = LaneNodeList[j].SelectNodes("lane-Speed");

                    Realtime_Detector.Realtime_Lane Temp_Lane = new Realtime_Detector.Realtime_Lane();

                    //Temp_Lane = new Realtime_Detector.Realtime_Lane();

                    try { Temp_Lane.Number = int.Parse(LaneNumberNode[0].InnerText); }
                    catch(Exception ex) { }
                    Temp_Lane.Status = LaneStatusNode[0].InnerText;
                    try { Temp_Lane.Occupancy = float.Parse(LaneOccupancyNode[0].InnerText); }
                    catch (Exception ex) { }
                    try { Temp_Lane.Speed = float.Parse(LaneSpeedNode[0].InnerText); }
                    catch (Exception ex) { }
                    try { Temp_Lane.Volume = float.Parse(LaneVolumeNode[0].InnerText); }
                    catch (Exception ex) { }

                    Temp.Lanes.Add(Temp_Lane);
                }

                _Detectors.Add(Temp);
            }
        }

        public void Write2DB()
        {
            Read();
            
            SqlConnection Conn = Connect2DB.GetInisitance();

            SqlTransaction Trans = Conn.BeginTransaction();

            for (int i = 0; i < _Detectors.Count; i++)
            {
                WriteSingleDetector2DB(_Detectors[i], Conn, Trans);
            }

            Trans.Commit();
        }

        private void WriteSingleDetector2DB(Realtime_Detector detector, SqlConnection conn, SqlTransaction trans)
        {
            int LaneNumber = detector.Lanes.Count;

            if (LaneNumber <= 0)
            {
                return;
            }

            _InsertCommand[LaneNumber - 1].Connection = conn;
            _InsertCommand[LaneNumber - 1].Transaction = trans;
            _InsertCommand[LaneNumber - 1].Parameters["year"].Value = _Year;
            _InsertCommand[LaneNumber - 1].Parameters["month"].Value = _Month;

            _InsertCommand[LaneNumber - 1].Parameters["Date_Time"].Value = _CommonInfo.ReceiveTime.ToString();
            _InsertCommand[LaneNumber - 1].Parameters["Agency"].Value = _CommonInfo.Agency;
            _InsertCommand[LaneNumber - 1].Parameters["DetectorID"].Value = detector.DetectorID;

            for (int i = 0; i < LaneNumber; i++)
            {
                _InsertCommand[LaneNumber - 1].Parameters[string.Format("Lane_Number_{0}", i + 1)].Value = detector.Lanes[i].Number;
                _InsertCommand[LaneNumber - 1].Parameters[string.Format("Lane_Status_{0}", i + 1)].Value = detector.Lanes[i].Status;
                _InsertCommand[LaneNumber - 1].Parameters[string.Format("Lane_Volume_{0}", i + 1)].Value = detector.Lanes[i].Volume;
                _InsertCommand[LaneNumber - 1].Parameters[string.Format("Lane_Occupancy_{0}", i + 1)].Value = detector.Lanes[i].Occupancy;
                _InsertCommand[LaneNumber - 1].Parameters[string.Format("Lane_Speed_{0}", i + 1)].Value = detector.Lanes[i].Speed;
            }

            float Volume_Ave = 0, Occupancy_Ave = 0, Speed_Ave = 0;

            for (int i = 0; i < LaneNumber; i++)
            {
                Volume_Ave += detector.Lanes[i].Volume;
                Occupancy_Ave += detector.Lanes[i].Occupancy;
                Speed_Ave += detector.Lanes[i].Speed;
            }

            _InsertCommand[LaneNumber - 1].Parameters["Lane_Volume_Ave"].Value = Volume_Ave / LaneNumber;
            _InsertCommand[LaneNumber - 1].Parameters["Lane_Occupancy_Ave"].Value = Occupancy_Ave / LaneNumber;
            _InsertCommand[LaneNumber - 1].Parameters["Lane_Speed_Ave"].Value = Speed_Ave / LaneNumber;
            
            _InsertCommand[LaneNumber - 1].ExecuteNonQuery();

        }

        public static bool TableExist(string tableName)
        {
            SqlCommand SelectCommand = new SqlCommand();
            SelectCommand.CommandText = string.Format("select * from sys.Tables where name = '{0}'", tableName);
            SelectCommand.Connection = Connect2DB.GetInisitance();

            bool RowEffect = true;

            using (SqlDataReader Reader = SelectCommand.ExecuteReader())
            {
                RowEffect = Reader.Read();
            }

            return RowEffect;
        }
    }

    public class Realtime_Common
    {
        private DateTime _ReceiveTime;

        internal DateTime ReceiveTime
        {
            get { return _ReceiveTime; }
            set { _ReceiveTime = value; }
        }
        private string _Agency;

        public string Agency
        {
            get { return _Agency; }
            set { _Agency = value; }
        }
    }

    public class Realtime_Detector
    {
        private string _DetectorID;

        public string DetectorID
        {
            get { return _DetectorID; }
            set { _DetectorID = value; }
        }
        private List<Realtime_Lane> _Lanes;

        public List<Realtime_Lane> Lanes
        {
            get { return _Lanes; }
            set { _Lanes = value; }
        }

        

        public Realtime_Detector()
        {
            _DetectorID = null;
            _Lanes = new List<Realtime_Lane>(5);
        }

        public class Realtime_Lane
        {
            public Realtime_Lane()
            {
                _Number = -1;
                _Occupancy = -1;
                _Speed = -1;
                _Status = "NULL";
                _Volume = -1;
            }

            private int _Number;

            public int Number
            {
                get { return _Number; }
                set { _Number = value; }
            }
            private string _Status;

            public string Status
            {
                get { return _Status; }
                set { _Status = value; }
            }
            private float _Volume;

            public float Volume
            {
                get { return _Volume; }
                set { _Volume = value; }
            }
            private float _Occupancy;

            public float Occupancy
            {
                get { return _Occupancy; }
                set { _Occupancy = value; }
            }
            private float _Speed;

            public float Speed
            {
                get { return _Speed; }
                set { _Speed = value; }
            }
        }

    }

    

}
