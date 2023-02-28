md %userprofile%\desktop\AppDiscovery
wevtutil sl "Microsoft-Windows-Kerberos-Key-Distribution-Center/Performance" /e:false /q
wevtutil epl Microsoft-Windows-Kerberos-Key-Distribution-Center/Performance %userprofile%\desktop\AppDiscovery\KDCPerf.evtx /overwrite
copy %SYSTEMROOT%\Debug\netlogon.log %userprofile%\desktop\AppDiscovery\netlogon.log
copy %SYSTEMROOT%\Debug\netlogon.bak %userprofile%\desktop\AppDiscovery\netlogon.bak
nltest /dbflag:0x0
reg delete HKLM\SOFTWARE\Policies\Microsoft\Netlogon\Parameters /v MaximumLogFileSize /f
