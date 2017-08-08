# IP
Using bitwise and otherwise calculations of numbers 32 bits and higher in a 32-bit environment to calculate 32-bit IPv4 and 128-bit IPv6 network information.

Ping_Test:

Monitor continuous ping statistics across a series of nodes.

Script_Calc:

Can calculate and convert numbers 32 bits and higher from a 32-bit environment.

Network_Calc:

Currently only calculates IPv4. Since IPv4 addresses take up exactly 32 bits, this script requires Script_Calc to accurately calculate the decimal conversion of an IP address because 32-bit environments are limited to only calculate 31-bit numbers because the 32nd bit is used for sign control in designating if a number is positive or negative. The decimal conversion is included in this script for the sole purpose of letting you know what it is, while all other calcluations are bitwise and don't require a decimal conversion. Once IPv6 is also included, Script_Calc will be required for all IPv6 calculations.

Note: The reverse IP address decimal conversion (/d /r) intentionally stays within 32-bit limitations to be able to convert to various executable output that stores data as a reverse 32-bit number (i.e. NirSoft/Nir Sofer INI files). The forward decimal conversion is usefule for various lookup tables that list networks in decimal (i.e. GeoLite2's optional decimal format).

GeoIP:

TBA. This script will output geographical and other information for any given IP address by incrementing subnet length iteratively to recurse through possible network IDs/CIDR calculated by Network_Calc until finding a match in GeoLite2.

GeoLite2:

Download and extract the following 2 zip files to the GeoLite2 subdirectory:

http://geolite.maxmind.com/download/geoip/database/GeoLite2-City-CSV.zip

http://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN-CSV.zip

The GeoLite2 databases are distributed under the Creative Commons Attribution-ShareAlike 4.0 International License.

These scripts reference using GeoLite2 data created by MaxMind, available from:
http://www.maxmind.com
