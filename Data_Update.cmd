@echo off

rem =====
rem For more information on ScriptTiger and more ScriptTiger scripts visit the following URL:
rem https://scripttiger.github.io/
rem Or visit the following URL for the latest information on this ScriptTiger script:
rem https://github.com/ScriptTiger/IP
rem =====

set MM=http://geolite.maxmind.com/download/geoip/database
set CURL=%MM%/GeoLite2-City-CSV.zip
set AURL=%MM%/GeoLite2-ASN-CSV.zip
set TURL=https://check.torproject.org/exit-addresses
set AVURL=http://reputation.alienvault.com/reputation.data
set DATA=%~dps0Data
set TOR=%DATA%\exit-addresses
set IN=%DATA%\GeoLite2-*.zip
set AV=%DATA%\reputation.data

if "%PROCESSOR_ARCHITECTURE%"=="" (set ARCH=x86) else (set ARCH=%PROCESSOR_ARCHITECTURE:~-2%)

set ZA=%~dps07za\x%ARCH%\7za.exe
set WGET="%~dps0wget\x%ARCH%\wget.exe" -nv --show-progress -P "%DATA%"

echo Downloading archives...

:Download_City
%WGET% %CURL% || goto Download_City

:Download_ASN
%WGET% %AURL% || goto Download_ASN

echo Deleting old Tor list...

if exist "%TOR%" del "%TOR%"

echo Downloading new Tor list...

:Download_Tor
%WGET% %TURL% || goto Download_Tor

echo Deleting old AlienVault data...

if exist "%AV%" del "%AV%"

echo Downloading new AlienVault data...

:Download_AV
%WGET% %AVURL% || goto Download_AV

echo Extracting archives...

%ZA% e -O%DATA% -y %IN% > nul

echo Deleting archives...

del %IN%

echo Update complete
if not "%1"=="/q" pause