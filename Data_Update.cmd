@echo off

rem =====
rem For more information on ScriptTiger and more ScriptTiger scripts visit the following URL:
rem https://scripttiger.github.io/
rem Or visit the following URL for the latest information on this ScriptTiger script:
rem https://github.com/ScriptTiger/IP
rem =====

set MM=http://geolite.maxmind.com/download/geoip/database
set CITY=GeoLite2-City-CSV.zip
set CURL=%MM%/GeoLite2-City-CSV.zip
set ASN=GeoLite2-ASN-CSV.zip
set AURL=%MM%/GeoLite2-ASN-CSV.zip
set TURL=https://check.torproject.org/exit-addresses
set DATA=%~dps0Data
set CITY=%DATA%\%CITY%
set ASN=%DATA%\%ASN%
set TOR=%DATA%\exit-addresses
set ZA=%~dps07za\7za.exe
set IN=%DATA%\GeoLite2-*.zip

set BITS=0
bitsadmin /list > nul && set /a BITS=%BITS%+1
powershell get-bitstransfer > nul && set /a BITS=%BITS%+2
if %BITS% geq 2 (
	set BITS_FROM=powershell Start-BitsTransfer -source
	set BITS_TO= -destination
)
if %BITS%==1 (
	set BITS_FROM=bitsadmin /transfer "" 
	set BITS_TO=
)
if %BITS%==0 (
	echo This script requires BITS to be installed
	pause
	exit
)

echo Downloading archives...

:Download_City
%BITS_FROM% %CURL% %BITS_TO% "%CITY%" || goto Download_City

:Download_ASN
%BITS_FROM% %AURL% %BITS_TO% "%ASN%" || goto Download_ASN

echo Deleting old Tor list...

del "%TOR%"

echo Downloading new Tor list...

:Download_Tor
%BITS_FROM% %TURL% %BITS_TO% "%TOR%" || goto Download_Tor

echo Extracting archives...

%ZA% e -O%DATA% -y %IN% > nul

echo Deleting archives...

del %IN%

echo Update complete
pause