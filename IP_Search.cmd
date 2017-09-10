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

echo ----- City Data -----
call :Find "%FINDSTR%" "%CITY4%" CITY

rem =====
rem Search ASN data for any of the possible networks
rem =====

echo ----- ASN Data -----
call :Find "%FINDSTR%" "%ASN4%" ASN

rem =====
rem Search Tor exit nodes to see if the IP is listed
rem =====

echo ----- Other Data -----
set TOR=No
for /f %%0 in ('findstr /b /l /c:"ExitAddress %IP%" "%TOR4%"') do set TOR=Yes
echo Known Tor Exit:	!TOR!
echo.

rem =====
rem Offer to open Google Maps locaction and prompt for a new IP if in interactive mode, otherwise exit
rem =====

if %INTERACTIVE%==1 (
	if not "!URL!"=="" (
		choice /m "Would you like to open the location in Google Maps now?"
		if !errorlevel!==1 explorer "!URL!"
	)
	goto IP
)

exit /b

rem =====
rem Functions
rem =====

rem =====
rem Search MaxMind data for entries matching any of the possible networks and call display functions for each match
rem =====

:Find
for /f "tokens=*" %%0 in ('findstr /b /l "%~1" "%~2"') do call :%3 %%0
exit /b

rem =====
rem Display matching city data
rem =====

:City
set CITY=
set URL=
call :Swap %*
if not "!DATA!"=="" (
	set DATA=%*
	set DATA=!DATA:,,=, ,!
	for /f "tokens=1,2,3,5,7,8,9,10 delims=," %%0 in ('echo !DATA!') do (
		echo City Network:	%%0
		if not "%%1"==" " for /f "tokens=2* delims=," %%a in ('findstr /b "%%1" "%LANG%"') do echo City:		%%b
		if not "%%2"==" " for /f "tokens=2* delims=," %%a in ('findstr /b "%%2" "%LANG%"') do echo Country:	%%b
		if "%%3"=="0" (echo Known Proxy:	No) else echo Known Proxy:	Yes
		if not "%%4"==" " echo Post Code:	%%~4
		if not "%%5"=="" if not "%%6"=="" (
			set URL=https://www.google.com/maps/@%%5,%%6,6z
			echo Google Maps:	!URL!
		)
		if not "%%7"=="" echo Accuracy:	%%7 km
		echo.
	)
)
exit /b

rem =====
rem Display matching ASN data
rem =====

:ASN
call :Swap %*
if not "!DATA!"=="" (
	set DATA=%*
	set DATA=!DATA:,,=, ,!
	for /f "tokens=1,2* delims=," %%0 in ('echo !DATA!') do (
		echo ASN Network:	%%0
		echo ASN:		%%1
		echo ISP:		%%~2
		echo.
	)
)
exit /b

rem =====
rem Swap problem characters
rem =====

:Swap
set DATA=%*
set DATA=!DATA:^"=DoubleQuote!
set DATA=!DATA:^(=OpenParantheses!
set DATA=!DATA:^)=CloseParantheses!
exit /b