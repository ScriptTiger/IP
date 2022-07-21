[![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://docs.google.com/forms/d/e/1FAIpQLSfBEe5B_zo69OBk19l3hzvBmz3cOV6ol1ufjh0ER1q3-xd2Rg/viewform)

**If you find these scripts useful, you may also be interested in checking out the reference implementation in the goIP repository, which contains much of the same functionality ported to Go and compiled to binaries for much faster results, as well as a REST API available for IP queries.  
goIP Reference Implementation: https://github.com/ScriptTiger/goIP/tree/main/ref  
goIP Binary Downloads: https://github.com/ScriptTiger/goIP/releases**

# IP
Tired of paying a subscription service to access an API to resolve geoIP data? Look no further! Resolving locally and maintaining your own database is easier than ever. This repo is everything IP: 32-bit/128-bit calculations, ping monitoring across multiple nodes, IPv4/IPv6 network calculations, geoip lookups.

Using bitwise and otherwise calculations of numbers 32 bits and higher in a 32-bit environment to calculate 32-bit IPv4 and 128-bit IPv6 network information.

7-Zip and wget are also components to this project licensed separately in accordance with their attached documentation.

Ping_Test:  
Monitor continuous ping statistics across a series of nodes.

Script_Calc:  
Can calculate and convert numbers 32 bits and higher from a 32-bit environment.

Network_Calc:  
Currently only calculates IPv4. Since IPv4 addresses take up exactly 32 bits, this script requires Script_Calc to accurately calculate the decimal conversion of an IP address because 32-bit environments are limited to only calculate 31-bit numbers because the 32nd bit is used for sign control in designating if a number is positive or negative. The decimal conversion is included in this script for the sole purpose of letting you know what it is, while all other calcluations are bitwise and don't require a decimal conversion. Once IPv6 is also included, Script_Calc will be required for all IPv6 calculations.  
Note: The reverse IP address decimal conversion (/d /r) intentionally stays within 32-bit limitations to be able to convert to various executable output that stores data as a reverse 32-bit number (i.e. NirSoft/Nir Sofer INI files). The forward decimal conversion is useful for various lookup tables that list networks in decimal (i.e. GeoLite2's optional decimal format).

IP_Search:  
Currently only supports searching IPv4 addresses. Thanks to MaxMind, non-numerical data has multilingual support! You can also use this script both interactively and scripted. For scripted searches with pretty output, just send the language and IP to search for to the script like this:  
`IP_Search.cmd en 8.8.8.8`  
The above command will search for 8.8.8.8 (Google DNS) and output the results in English.  
For scripted searches in CSV format:  
`IP_Search.cmd csv 8.8.8.8 C:\SomeFile.csv`  
The above command will search for 8.8.8.8 (Google DNS) and output the results in CSV format to the file C:\SomeFile.csv. You can optionally not specify a file name to allow output to the console.  
Language options are as follows:  
de  
en  
es  
fr  
ja  
pt-BR  
ru  
zh-CN  
Because GeoLite2 is the free product from MaxMind, the accuracy is obviously not going to be as good as the paid product, and neither are 100%. The only thing this search script CAN do with nearly 100% accuracy, assuming you have just recently run the Data_Update.cmd, is detect Tor nodes, as the Tor exit node list is provided directly from the Tor Project and is separate from the MaxMind data. The following is the current output of the script:

Output Field            | Explanation
------------------------|-------------------------------------------------------------------------------------------------------
----- WAN Data -----
WAN:                    | Target IP's parent wide area network
Continent:              | Continent on which the target IP resides
Country:                | Country in which the target IP resides
Subdivisin 1:           | Major subdivision in which the target IP resides
Subdivisin 2:           | Minor subdivision in which the target IP resides
City:                   | City in which the target IP resides
Metro Code:             | Metro code to the target IP's surrounding area
Time Zone:              | Time zone of the target IP's surrounding area
EU:                     | Is the target IP in the EU (Yes/No)
Registered Country:     | Country to which the target IP is registered
------------------------| Displayed as: Country, Continent (Time zone)
Represented Country:    | Foreign national representation possessing the IP
------------------------| Displayed as: Country, Continent (Time zone)
Known Proxy:            | Does the target IP host a known proxy server (Yes/No)
Post Code:              | Post code to the target IP's surrounding area
Google Maps:            | Google Maps link to view the IP's approximate location
Accuracy:               | Approximate accuracy of the target IP's location results
----- ASN Data -----
ASN Network:            | Network to which the target IP's covering ASN spans
ASN:                    | Autonomous system number covering the target IP
ISP:                    | ISP controlling the target IP's covering ASN
----- Other Data -----
Known Tor Exit:         | Does the target IP host a known Tor exit node (Yes/No)
Blacklisted by Snort:   | Is the target IP blacklisted by Snort (Yes/No)

Data_Update.cmd:  
Will automatically download the latest data from all sources to the Data subdirectory:  
GeoLite2 (requires free or paid MaxMind license key from https://www.maxmind.com/en/my_license_key written to license_key.txt in the same directory)  
https://check.torproject.org/exit-addresses  
http://reputation.alienvault.com/reputation.data  
https://talosintelligence.com/documents/ip-blacklist


These scripts reference using GeoLite2 data created by MaxMind, available from:  
http://www.maxmind.com

The GeoLite2 databases are distributed under the Creative Commons Attribution-ShareAlike 4.0 International License.

You can download this repo from the below link to get started:  
https://github.com/ScriptTiger/IP/archive/master.zip

For more ScriptTiger scripts and goodies, check out ScriptTiger's GitHub Pages website:  
https://scripttiger.github.io/

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MZ4FH4G5XHGZ4)

Donate Monero (XMR): 441LBeQpcSbC1kgangHYkW8Tzo8cunWvtVK4M6QYMcAjdkMmfwe8XzDJr1c4kbLLn3NuZKxzpLTVsgFd7Jh28qipR5rXAjx
