# Sample Output

Below is an image of the initial view shown by PowerBI after capturing the data. Initial view will visualize the amount of kerberos authentications for each service principles and user/client that requested it.

* Number of KERB Auths
  * shows the number of Kerberos Authentications that were captured in the .evtx file
* Filter out Domain Controllers
  * domain controllers can be filtered out of the reults by CTRL + Clicking on the buttons
* Filter by Protocol
  * specific protocols can be targetted by selecting the respective protocols from the list
* Filtered Results
  * Left barchart provides the list service principals that were targeted for the Kerberos Authentication.
  * Right barchart provides the list of users(clients) that requested the Kerberos Authentication.
 
![alt text](https://github.com/gentarom/AppDiscoveryTool/blob/main/FilesForThisGithubSite/00SampleImage-Kerb.jpg)

Kerberos Authentications are often used by Active Directory. Filter options are provided to filter out these uninteresting authentications to help you identify Application Servers.  For example, in order to identify file servers, we can select the "cifs" protocol and also exclude domain controllers by ctrl+clicking on the "Exclude DCs." This will update the results as below - listing the service principles with high possiblities of being a File Server.

![alt text](https://github.com/gentarom/AppDiscoveryTool/blob/main/FilesForThisGithubSite/02SampleImage-ExcludeDCOnlyCIFS.jpg)

You can further identify the users authenticaing with the specific service principle by clicking on the service principle of interest. For example, clicking on the  service principle (cifs/hdw12.phs.gentoso.com) as below shows that a large proportion of the authentication is being requested by one client (USBFIL835$@phs.gentoso.com). These information should help you further identify the application servers and its purpose.

![alt_text](https://github.com/gentarom/AppDiscoveryTool/blob/main/FilesForThisGithubSite/03SampleImage-HighlightServer.jpg)

Clicking on the "NTLMAuth" tab on the far buttom will show similar results for the NTLM authentications captured in the netlogon.log. Similar to above, we have the list of authenticating servers on the left and the respective user accounts on the right.  

![alt_text](https://github.com/gentarom/AppDiscoveryTool/blob/main/FilesForThisGithubSite/01SampleImage-NTLM.jpg)
