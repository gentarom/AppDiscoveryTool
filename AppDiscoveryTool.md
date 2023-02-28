# Application Discovery Tool

* Overview
  * [About This tool](https://github.com/gentarom/AppDiscoveryTool#about-this-tool)
  * [Pre-req](https://github.com/gentarom/AppDiscoveryTool#pre-req)
* Instructions
  * [How To Run This Tool](https://github.com/gentarom/AppDiscoveryTool#step-0-select-target-domain-controller)
  * [Sample Output](https://github/gentarom/AppDiscoveryTool)
* References
  * [FAQ/Additional Info](https://github.com/gentarom/AppDiscoveryTool#additional-info)
<br>
<br>
<br>

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


