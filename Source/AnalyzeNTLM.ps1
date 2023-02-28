$code = @"
using System;
using System.IO;
using System.Collections.Generic;

namespace AnalyzeNTLMCSharp
{
    public class Program
    {
        public static void Main(string[] args)
        {
            string LogFilePath = null;
            
            //Check arguments
            if (args.Length == 1)
            {
                LogFilePath = args[0];
                Console.WriteLine("Analyzing : " + args[0]);
            }
            //else if (File.Exists("netlogon.log"))
            //{
            //    LogFilePath = "netlogon.log";
            //    Console.WriteLine("Analyzing netlogon.log file in the current directory");
            //}
            else
            {
                Console.WriteLine("Specify netlogon file as AnalyzeNTLM.ps1 <Netlogon.log>");
                return;
            }

            //Read the netlogon.log and parse it. (Store items in AllNTLMAuth list as we parse it)
            List<string> AllNTLMAuth = new List<string>();
            string[] WholeLogFile = System.IO.File.ReadAllLines(LogFilePath);

            foreach (string OneLine in WholeLogFile)
            {
                if (OneLine.Contains("SamLogon: Transitive Network logon") && OneLine.Contains("Returns 0x0"))
                {
                    // sample output (Transitive Network logon)
                    // 01/27 06:32:27 [LOGON] [816] DOMAIN: SamLogon: Transitive Network logon of DOMAIN\gentaro from Client (via Server) Returns 0x0 

                    //split with spaces
                    string[] parts = OneLine.Split(' ');

                    //14th character holds "ServerName)". remove the closing bracket at the end of the ServerName.
                    parts[14] = parts[14].Substring(0, parts[14].Length - 1);

                    //Format the parts we want as csv
                    string SingleAuth;
                    SingleAuth = parts[14] + "," + parts[10] + "," + parts[12] + "," + "SamLogon: Transitive Network logon" + "," + parts[0] + " " + parts[1];

                    //keep track
                    AllNTLMAuth.Add(SingleAuth);
                }
                else if (OneLine.Contains("SamLogon: Network logon") && OneLine.Contains("Returns 0x0"))
                {
                    // sample output (Network logon)
                    // 04/15 14:23:22 [LOGON] [3748] DOMAIN: SamLogon: Network logon of DOMAIN\gentaro from Client Returns 0x0
                    // 05/13 17:47:46 [LOGON] [8244] DOMAIN: SamLogon: Network logon of DOMAIN\gentaro from Client (via Server) Returns 0x0

                    //split with spaces
                    string[] parts = OneLine.Split(' ');

                    //13th character may hold "ServerName)". If it holds 0x0, replace it with Null otherwise remove the closing bracket at the end of the ServerName.
                    if (String.Compare(parts[13], "0x0") == 0)
                    {
                        parts[13] = "null";
                    }
                    else
                    {
                        parts[13] = parts[13].Substring(0, parts[13].Length - 1);
                    }

                    //Format the parts we want as csv
                    string SingleAuth;
                    SingleAuth = parts[13] + "," + parts[9] + "," + parts[11] + "," + "SamLogon: Network logon" + "," + parts[0] + " " + parts[1];

                    //keep track
                    AllNTLMAuth.Add(SingleAuth);
                }
            }

            //export AllNTLMAuth as csv to (DESKTOP)\AppDiscovery\NTLMAuthRaw.csv
            string CSVFilePath = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory) + @"\AppDiscovery" ;
            string CSVFileName = CSVFilePath + @"\NTLMAuthRAW.csv";
            System.IO.Directory.CreateDirectory(CSVFilePath);

            Console.WriteLine("Exporting Results to CSV");
            TextWriter tw = new StreamWriter(CSVFileName);
            tw.WriteLine("ServerName,UserName,ClientName,Type,DateTime");

            foreach(string ThisAuth in AllNTLMAuth)
            {
                tw.WriteLine(ThisAuth);
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
[AnalyzeNTLMCSharp.Program]::Main( $args )

Write-Output ""
