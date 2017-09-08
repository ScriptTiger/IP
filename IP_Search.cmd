@echo off

rem =====
rem For more information on ScriptTiger and more ScriptTiger scripts visit the following URL:
rem https://scripttiger.github.io/
rem Or visit the following URL for the latest information on this ScriptTiger script:
rem https://github.com/ScriptTiger/IP
rem =====

rem =====
rem Environmental setup
rem =====

setlocal ENABLEDELAYEDEXPANSION

set DATA=%~dp0Data
set CITY4=%DATA%\GeoLite2-City-Blocks-IPv4.csv
set CITY6=%DATA%\GeoLite2-City-Blocks-IPv6.csv
set ASN4=%DATA%\GeoLite2-ASN-Blocks-IPv4.csv
set ASN6=%DATA%\GeoLite2-ASN-Blocks-IPv6.csv
set TOR4=%DATA%\exit-addresses
set NETCALC=%~dp0Network_Calc.cmd

rem Set default mode as interactive
set INTERACTIVE=1

rem =====
rem Set language preference
rem =====

if "%~1"=="" (
	echo 1.] Deutsche
	echo 2.] English
	echo 3.] Español
	echo 4.] Français
	echo 5.] Nihongo
	echo 6.] Portugues ^(Brasil^)
	echo 7.] Russkiy
	echo 8.] Zhongwén ^(Jianhuàzì^)
	choice /c 12345678 /n
	if !errorlevel!==1 set LANG=de
	if !errorlevel!==2 set LANG=en
	if !errorlevel!==3 set LANG=es
	if !errorlevel!==4 set LANG=fr
	if !errorlevel!==5 set LANG=ja
	if !errorlevel!==6 set LANG=pt-BR
	if !errorlevel!==7 set LANG=ru
	if !errorlevel!==8 set LANG=zh-CN
) else set LANG=%~1
set LANG=%DATA%\GeoLite2-City-Locations-%LANG%.csv

rem =====
rem Set IP to search for
rem =====

:IP
if "%~2"=="" (set /p IP=IP: || exit /b) else (
	set IP=%~2
	set INTERACTIVE=0
)

rem =====
rem Build search string of all possible networks
rem =====

set FINDSTR=
for /l %%0 in (0,1,32) do (
	for /f %%a in ('%NETCALC% /id %IP%/%%0') do set FINDSTR=!FINDSTR!%%a, 
)

rem =====
rem Search city data for any of the possible networks
rem =====

set CITY=
call :Find "%FINDSTR%" "%CITY4%" CITY

rem =====
rem Search ASN data for any of the possible networks
rem =====

set ASN=
call :Find "%FINDSTR%" "%ASN4%" ASN

rem =====
rem Search Tor exit nodes to see if the IP is listed
rem =====

set TOR=No
for /f %%0 in ('findstr /b /l /c:"ExitAddress %IP%" "%TOR4%"') do set TOR=Yes

rem =====
rem Display matching city data
rem =====

set COUNTRY=
set PROXY=
set POST=
set URL=
set ACCURACY=
if not "!CITY!"=="" (
	set CITY=!CITY:,,=, ,!
	for /f "tokens=2,3,5,7,8,9,10 delims=," %%0 in ('echo !CITY!') do (
		set CITY=%%0
		set COUNTRY=%%1
		set PROXY=%%2
		set POST=%%3
		if not "%%4"=="" if not "%%5"=="" set URL=https://www.google.com/maps/@%%4,%%5,6z
		if not "%%6"=="" set ACCURACY=%%6 km
	)
	if not "!CITY!"==" " for /f "tokens=2* delims=," %%a in ('findstr /b "!CITY!" "%LANG%"') do set CITY=%%b
	if not "!COUNTRY!"==" " for /f "tokens=2* delims=," %%a in ('findstr /b "!COUNTRY!" "%LANG%"') do set COUNTRY=%%b
	if "!PROXY!"=="0" (set PROXY=No) else set PROXY=Yes
	echo City:		!CITY!
	echo Post Code:	!POST!
	echo Country:	!COUNTRY!
	echo Proxy:		!PROXY!
	echo Google Maps:	!URL!
	echo Accuracy:	!ACCURACY!
) else echo No City Data found for this Public IP

rem =====
rem Display matching ASN data
rem =====

set ISP=
if not "!ASN!"=="" (
	for /f "tokens=2* delims=," %%a in ('echo !ASN!') do (
		set ASN=%%a
		set ISP=%%~b
	)
	echo ASN:		!ASN!
	echo ISP:		!ISP!
) else echo No ASN Data found for this Public IP

rem =====
rem Display Matching Tor data
rem =====

echo Tor Node:	!TOR!

rem Pause before exiting if in interactive mode
if %INTERACTIVE%==1 (
	if not "!URL!"=="" (
		choice /m "Would you like to open the location in Google Maps now?"
		if !errorlevel!==1 explorer "!URL!"
	)
	goto IP
)

exit /b

rem =====
rem Function for searching MaxMind data for entries matching any of the possible networks
rem =====

:Find
for /f "tokens=*" %%0 in ('findstr /b /l "%~1" "%~2"') do set %~3=%%0
exit /b