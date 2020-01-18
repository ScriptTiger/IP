@echo off

rem =====
rem For more information on ScriptTiger and more ScriptTiger scripts visit the following URL:
rem https://scripttiger.github.io/
rem Or visit the following URL for the latest information on this ScriptTiger script:
rem https://github.com/ScriptTiger/IP
rem =====

set LKT=%~dps0license_key.txt

if exist %LKT% (
	set /p MML=<%LKT%
) else (
	echo You currently don't have a MaxMind license key configured.
	echo Please visit the following address to obtain a free or paid key:
	echo https://www.maxmind.com/en/my_license_key
	set /p MML=MaxMind License Key: 
)

if not exist %LKT% echo %MML%>%LKT%

set MM=https://download.maxmind.com/app/geoip_download?suffix=zip
set CURL="%MM%&license_key=%MML%&edition_id=GeoLite2-City-CSV"
set AURL="%MM%&license_key=%MML%&edition_id=GeoLite2-ASN-CSV"
set TURL=https://check.torproject.org/exit-addresses
set AVURL=http://reputation.alienvault.com/reputation.data
set IPBURL=https://talosintelligence.com/documents/ip-blacklist
set DATA=%~dps0Data
set TOR=%DATA%\exit-addresses
set IN=%DATA%\geoip_download*-CSV
set AV=%DATA%\reputation.data
set IPB=ip-blacklist
set IPBF=%DATA%\%IPB%

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

echo Deleting old Snort IP Blacklist...

if exist "%IPBF%" del "%IPBF%"

echo Downloading new Snort IP Blacklist...

:Download_IPB
%WGET% %IPBURL% || goto Download_IPB

echo Converting Snort IP Blacklist to CRLF...

if exist "%IPBF%.tmp" del "%IPBF%.tmp"

(
	for /f %%0 in ('type "%IPBF%"') do echo %%0
) > "%IPBF%.tmp"

del "%IPBF%"

ren "%IPBF%.tmp" "%IPB%"

echo Extracting archives...

%ZA% e -O%DATA% -y %IN% > nul

echo Deleting archives...

del %IN%

echo Update complete
if not "%1"=="/q" pause
