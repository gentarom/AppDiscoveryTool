$code = @"
using System;
using System.Diagnostics.Eventing.Reader;
using System.IO;
using System.Collections.Generic;

namespace AnalyzeKerbCSharp
{
    public class Program
    {
        public static void Main(string[] args)
        {

            string LogFilePath; // = @"C:\Users\nuntaro\source\repos\AnalyzeKerbCSharp\AnalyzeKerbCSharp\obj\Debug\KDCPerf.evtx";

            //Check arguments            
            if (args.Length == 1)
            {
                LogFilePath = args[0];
                Console.WriteLine("Analyzing : " + args[0]);
            }
            //else if (File.Exists("KDCPerf.evtx"))
            //{
            //    LogFilePath = "KDCPerf.evtx";
            //    Console.WriteLine("Analyzing KDCPerf.evtx file in the current directory");
            //}
            else
            {
                Console.WriteLine("Specify KDCPerf.evtx file as AnalyzeKerb.ps1 <KDCPerf.evtx>");
                return;
            }            

            //Parse each records in .evtx file
            List<string> AllKerbAuth = new List<string>();
            int count = 0;

            using (var reader = new EventLogReader(LogFilePath, PathType.FilePath))
            {
                EventRecord record;
                for (record = reader.ReadEvent(); record != null; record = reader.ReadEvent())
                {
                    using (record)
                    {
                        if (record.Id == 103)
                        {
                            //Parse each line from event ID 103 and store the values.
                            string DescriptionString = record.FormatDescription();
                            using (StringReader strReader = new StringReader(DescriptionString))
                            {
                                string OneLine = null;
                                string ClientDomain = null;
                                string ClientName = null;
                                string ServerDomain = null;
                                string ServerName = null;
                                string ErrorCode = null;

                                while ((OneLine = strReader.ReadLine()) != null)
                                {
                                    //extract each parts from description
                                    string[] parts = OneLine.Split(':');

                                    if (OneLine.Contains("client domain:")) { ClientDomain = parts[1].Trim(); }
                                    else if (OneLine.Contains("client name:")) { ClientName = parts[1].Trim(); }
                                    else if (OneLine.Contains("server domain:")) { ServerDomain = parts[1].Trim(); }
                                    else if (OneLine.Contains("server name:")) { ServerName = parts[1].Trim(); }
                                    else if (OneLine.Contains("ErrorCode:")) { ErrorCode = parts[1].Trim(); }

                                }
                                //If ErrorCode is 0x0 keep track of this TGS in AllKerbAuth list as ClientDomain,ClientName,ServerDomain,ServerName,DateTime
                                if (ErrorCode.Equals("0x0"))
                                {
                                    string SingleAuth = ClientDomain + "," + ClientName + "," + ServerDomain + "," + ServerName + "," + record.TimeCreated;
                                    AllKerbAuth.Add(SingleAuth);
                                }
                            }
                        }
                    }

                    //This loop may take some time. print "." to show its still running.
                    count++;
                    if (count == 10000){ Console.Write("."); count = 0; }
                }
            }

            //export contents of AllKerbAuth as csv file.
            string CSVFilePath = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory) + @"\AppDiscovery";
            string CSVFileName = CSVFilePath + @"\KerbAuthRAW.csv";
            System.IO.Directory.CreateDirectory(CSVFilePath);

            Console.WriteLine("");
            Console.WriteLine("Exporting Results to CSV");
            TextWriter tw = new StreamWriter(CSVFileName);
            tw.WriteLine("ClientDomain,ClientName,ServerDomain,ServerName,DateTime");

            foreach (string OneAuth in AllKerbAuth)
            {
                tw.WriteLine(OneAuth);
            }
            tw.Close();

            Console.WriteLine("Exported Results to {0}", CSVFileName);

        }
    }
}
"@



#modify parameter to show full path
if($args.Count -eq 1)
{
  #netlogon.log needs to be in full path
  $args[0] = (Resolve-Path $args[0]).Path
}

Add-Type -TypeDefinition $code -Language CSharp 
[AnalyzeKerbCSharp.Program]::Main( $args )

Write-Output ""