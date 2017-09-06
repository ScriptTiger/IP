@echo off

rem =====
rem For more information on ScriptTiger and more ScriptTiger scripts visit the following URL:
rem https://scripttiger.github.io/
rem Or visit the following URL for the latest information on this ScriptTiger script:
rem https://github.com/ScriptTiger/IP
rem =====

setlocal ENABLEDELAYEDEXPANSION

set DATA=%~dp0GeoLite2
set CITY4=%DATA%\GeoLite2-City-Blocks-IPv4.csv
set CITY6=%DATA%\GeoLite2-City-Blocks-IPv6.csv
set ASN4=%DATA%\GeoLite2-ASN-Blocks-IPv4.csv
set ASN6=%DATA%\GeoLite2-ASN-Blocks-IPv6.csv
set LANG=en
set LANG=%DATA%\GeoLite2-City-Locations-%LANG%.csv
set NETCALC=%~dp0Network_Calc.cmd

set /p IP=IP: 

:GeoIP
for /l %%0 in (32,-1,0) do (
	for /f %%a in ('%NETCALC% /id %IP%/%%0') do set NETWORK=%%a
	call :Find !NETWORK! "%CITY4%" GeoIP ASN
)

echo No GeoIP Data found for this Public IP

:ASN
for /l %%0 in (32,-1,0) do (
	for /f %%a in ('%NETCALC% /id %IP%/%%0') do set NETWORK=%%a
	call :Find !NETWORK! "%ASN4%" ASN Exit
)
echo No ASN Data found for this Public IP
goto Exit

:Find
(for /f "tokens=*" %%a in ('findstr "^%~1" "%~2"') do set %~3=%%a) && goto %~4
exit /b

:Exit
for /f "tokens=2 delims=," %%a in ('echo !GeoIP!') do set CITY=%%a
for /f "tokens=3 delims=," %%a in ('echo !GeoIP!') do set COUNTRY=%%a
for /f "tokens=2* delims=," %%a in ('echo !ASN!') do set ASN=%%~b
for /f "tokens=*" %%a in ('findstr "^%CITY%" "%LANG%"') do set CITY=%%a
for /f "tokens=*" %%a in ('findstr "^%COUNTRY%" "%LANG%"') do set COUNTRY=%%a
echo City Data:	!CITY!
echo Country Data:	!COUNTRY!
echo ASN Data:	!ASN!
pause
exit