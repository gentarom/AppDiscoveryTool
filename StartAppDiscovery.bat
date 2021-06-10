wevtutil sl "Microsoft-Windows-Kerberos-Key-Distribution-Center/Performance" /ms:268435456 /rt:true /e:true /q
reg add HKLM\SOFTWARE\Policies\Microsoft\Netlogon\Parameters /v MaximumLogFileSize /t REG_DWORD /d 268435456
nltest /dbflag:0x00001004
gpupdate /force

