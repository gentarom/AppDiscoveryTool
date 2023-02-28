# Application Discovery Tool

## About This Tool
In Active Directory, authentications for domain users are processed by the domain controller. This tool will enable debug logs on the domain controller(s) to capture NTLM and Kerberos Authentications. We can then analyze the logs visually through Power BI to identify application servers that rely on your on-premises AD for authentication
<br>
<br>
<br>
## Pre-req
1.5 GB of disk space
<br>
<br>
<br>

## Step 0: Select target domain controller
Select domain </span>controller(s) you wish to analyze. You will need to run the following instructions on each domain controllers you wish to analyze. 
See "Aditional Info" section for more details about which domain controllers to select.
<br>
<br>
<br>

## Step 1: Enable Logging on the targetted Domain Controller
### 1. Open Command Prompt with Admin privilege. Run StartAppDiscovery.bat to enable logging.
```
What does StartAppDiscovery.bat execute?
1. The following command enables event log debugging for KDC/Performance (circular logging / max size = 256MB)
 * wevtutil sl "Microsoft-Windows-Kerberos-Key-Distribution-Center/Performance" /ms:268435456 /rt:true /e:true /q

2. The following commands enable netlogon logging (max size = 256 x 2)
 * reg add HKLM\SOFTWARE\Policies\Microsoft\Netlogon\Parameters /v MaximumLogFileSize /t REG_DWORD /d 268435456
 * nltest /dbflag:0x00001004
 * gpupdate /force
```

### 2. Wait while the domain controller(s) authenticates. 

### 3.	Run StopAppdiscovery.bat with admin privilege to stop logging and get data. 
```
What does StopAppdiscovery.bat execute?
1.	Create a folder named AppDiscovery on the desktop to export all data
 * md %userprofile%\desktop\AppDiscovery
 
2.	Stop event log debugging and export it to the AppDiscovery folder
 * wevtutil sl "Microsoft-Windows-Kerberos-Key-Distribution-Center/Performance" /e:false /q
 * wevtutil epl Microsoft-Windows-Kerberos-Key-Distribution-Center/Performance %userprofile%\desktop\AppDiscovery\KDCPerf.evtx /overwrite
 
3.	Disable netlogon logging and copy the files to the AppDiscovery folder 
 * copy %SYSTEMROOT%\Debug\netlogon.log %userprofile%\desktop\AppDiscovery\netlogon.log
 * copy %SYSTEMROOT%\Debug\netlogon.bak %userprofile%\desktop\AppDiscovery\netlogon.bak
 * nltest /dbflag:0x0
 * reg delete HKLM\SOFTWARE\Policies\Microsoft\Netlogon\Parameters /v MaximumLogFileSize /f

4. Get List of Domain Controllers
 * powershell -command "Get-ADDomainController -Filter * | Select-Object name | Export-Csv -Path .\ListOfDCs.csv"

```
<br>
<br>
<br>


## Step 2: Analyze Data
### 1.	Run the following powershell script to analyze NTLM authentications and create NTLMAuthRaw.csv
&nbsp;&nbsp;&nbsp; AnalyzeNTLM.ps1 <netlogon.log> 

### 2. Run the following powershell script to analyze Kerberos authentications and create KerbAuthRaw.csv. (requires KDC service when running on non-domain controllers)
&nbsp;&nbsp;&nbsp; AnalyzeKDCPerf <KDCPerf.evtx>

<br>
The output files (NTLMAuthRaw.csv and KerbAuthRaw.csv) contains information of all NTLM and Kerberos authentications that were handled by the domain controller. You can use the csv as is or visualize the results by passing these files as data sources into AnalyzeDCAuth.pbix


<br>
<br>
<br>

## Additional Info 
### Is this tool safe to run on a domain controller?
These are generic debug logs with max log size limited to a total of 1.5GB. It is unlikely that a performance issue will occur by enabling these logs but we recommend you first try this in your test environment before enabling it in production environment. Also, consider starting from targeting only few domain controllers so that clients can failover to other domain controller if such issues occur.

### How long should I wait after running StartAppDiscovery.bat?
Depends on the environment. The more authentication requests the domain controller processes while waiting, the more detailed output we will get. After the debug logs are enabled, each log may grow up to 256MB. These are circular logs so the contents are overwritten with the new logs once it reaches the max size. Just as a reference, a KDC event log that contained 356K Kerberos authentications was around 200MB and netlogon log that contained 378K NTLM authentications was around 121MB

### I think we’re missing some authentications.. 
Each domain controller process authentications independently, therefore we will not see the authentication if a domain controller we did not target processed the authentication request.

### How do clients determine which domain controler it should authenticate with.
The client prioritizes the closest domain controllers based on your site configuration. If no available domain controllers are found on its site, the client will search for any domain controller and authenticate with the fastest responding one.

[How domain controllers are located in Windows](https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/how-domain-controllers-are-located)


