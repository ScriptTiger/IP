@echo off

rem =====
rem For more information on ScriptTiger and more ScriptTiger scripts visit the following URL:
rem https://scripttiger.github.io/
rem Or visit the following URL for the latest information on this ScriptTiger script:
rem https://github.com/ScriptTiger/IP
rem =====

set CURL=http://geolite.maxmind.com/download/geoip/database/GeoLite2-City-CSV.zip
set AURL=http://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN-CSV.zip
set TURL=https://check.torproject.org/exit-addresses
set PREFIX=%~dps0Data
set WGET=%~dps0wget\x%PROCESSOR_ARCHITECTURE:~-2%\wget.exe -nv --show-progress -P %PREFIX%
set ZA=%~dps07za\7za.exe
set IN=%PREFIX%\GeoLite2-*.zip

echo Downloading archives...

:Download_City
%WGET% %CURL% || goto Download_City

:Download_ASN
%WGET% %AURL% || goto Download_ASN

Deleting old Tor list...

del "%PREFIX%\exit-addresses"

echo Downloading new Tor list...

:Download_Tor
%WGET% %TURL% || goto Download_Tor

echo Extracting archives...

%ZA% e -O%PREFIX% -y %IN% > nul

echo Deleting archives...

del %IN%