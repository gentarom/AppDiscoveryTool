# How To Run This Tool
<br>

## Step 0: Select target domain controller
Select domain </span>controller(s) you wish to analyze. You will need to run the following instructions on each domain controllers you wish to analyze. 
See [Additional Info](https://github.com/gentarom/AppDiscoveryTool/blob/main/FilesForThisGithubSite/AppDiscoveryTool.md#additional-info) section for more details about which domain controllers to select.
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
1. Create a folder named AppDiscovery on the desktop to export all data
 * md %userprofile%\desktop\AppDiscovery
 
2. Stop event log debugging and export it to the AppDiscovery folder
 * wevtutil sl "Microsoft-Windows-Kerberos-Key-Distribution-Center/Performance" /e:false /q
 * wevtutil epl Microsoft-Windows-Kerberos-Key-Distribution-Center/Performance %userprofile%\desktop\AppDiscovery\KDCPerf.evtx /overwrite
 
3. Disable netlogon logging and copy the files to the AppDiscovery folder 
 * copy %SYSTEMROOT%\Debug\netlogon.log %userprofile%\desktop\AppDiscovery\netlogon.log
 * copy %SYSTEMROOT%\Debug\netlogon.bak %userprofile%\desktop\AppDiscovery\netlogon.bak
 * nltest /dbflag:0x0
 * reg delete HKLM\SOFTWARE\Policies\Microsoft\Netlogon\Parameters /v MaximumLogFileSize /f

4. Get List of Domain Controllers
 * powershell -command "Get-ADDomainController -Filter * | Select-Object name | Export-Csv -Path %userprofile%\desktop\AppDiscovery\ListOfDCs.csv"

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
