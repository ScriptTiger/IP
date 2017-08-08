@echo off

set CURL=http://geolite.maxmind.com/download/geoip/database/GeoLite2-City-CSV.zip
set AURL=http://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN-CSV.zip
set PREFIX=%~dps0
set WGET=%~dps0wget\x%PROCESSOR_ARCHITECTURE:~-2%\wget.exe -nv --show-progress -P %PREFIX%
set ZA=%~dps07za\7za.exe
set IN=%PREFIX%GeoLite2-*.zip
set OUT=%~dps0GeoLite2

echo Downloading archives...

:Download_City
%WGET% %CURL% || goto Download_City

:Download_ASN
%WGET% %AURL% || goto Download_ASN

echo Extracting archives...

%ZA% e -O%OUT% -y %IN% > nul

echo Deleting archives...

del %IN%