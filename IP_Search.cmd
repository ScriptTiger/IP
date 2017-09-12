@echo off

rem =====
rem For more information on ScriptTiger and more ScriptTiger scripts visit the following URL:
rem https://scripttiger.github.io/
rem Or visit the following URL for the latest information on this ScriptTiger script:
rem https://github.com/ScriptTiger/IP
rem =====

rem =====
rem Parameters for Help
rem =====

if /i "%~1"=="help" goto Help
if /i "%~1"=="/help" goto Help
if /i "%~1"=="--help" goto Help
if "%~1"=="?" goto Help
if "%~1"=="/?" goto Help
if "%~1"=="--?" goto Help

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

echo ----- WAN Data -----
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
echo Known Tor Exit:		!TOR!
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
rem Search MaxMind data for entries matching any of the possible networks, format the matching entries, and call display functions for each match
rem =====

:Find
for /f "tokens=*" %%0 in ('findstr /b /l "%~1" "%~2"') do (
	call :Format_String %%0
	call :%3 !DATA!
)
exit /b

rem =====
rem Display matching city data
rem =====

:City
set URL=
if not "%*"=="" (
	for /f "tokens=1,2,3,4,5,7,8,9,10 delims={}" %%0 in ('echo %*') do (
		call :Display "WAN:			" "%%~0"
		if not "%%~1"=="\Null\" call :Resolve_City %%~1
		if not "%%~2"=="\Null\" call :Resolve_Country %%~2 Registered
		if not "%%~3"=="\Null\" call :Resolve_Country %%~3 Represented
		if "%%~4"=="0" (call :Display "Known Proxy:		" "No") else call :Display "Known Proxy:		" "Yes"
		call :Display "Post Code:		" "%%~5"
		if not "%%~6"=="\Null\" if not "%%~7"=="\Null\" (
			set URL=https://www.google.com/maps/@%%~6,%%~7,6z
			call :Display "Google Maps:		" "!URL!"
		)
		if not "%%~8"=="" call :Display "Accuracy:		" "%%~8 km"
		echo.
	)
)
exit /b

rem =====
rem Resolve and break down city strings
rem =====

:Resolve_City
for /f "tokens=3* delims=," %%a in ('findstr /b "%~1," "%LANG%"') do (
	call :Format_String %%b
	for /f "tokens=1,3,5,7,8,9,10 delims={}" %%0 in ('echo !DATA!') do (
		call :Display "Continent:		" "%%~0"
		call :Display "Country:		" "%%~1"
		call :Display "Subdivisin 1:		" "%%~2"
		call :Display "Subdivisin 2:		" "%%~3"
		call :Display "City:			" "%%~4"
		call :Display "Metro Code:		" "%%~5"
		call :Display "Time Zone:		" "%%~6"
	)
)
exit /b

rem =====
rem Resolve and break down country strings
rem =====

:Resolve_Country
for /f "tokens=3* delims=," %%a in ('findstr /b "%~1," "%LANG%"') do (
	call :Format_String %%b
	for /f "tokens=1,3,10 delims={}" %%0 in ('echo !DATA!') do (
		set DATA=%%~1, %%~0
		if not "%%~2"=="" set DATA=!DATA! \OpenParantheses\%%~2\CloseParantheses\
		call :Display "%~2 Country:	" "!DATA!"
	)
)
exit /b

rem =====
rem Display matching ASN data
rem =====

:ASN
if not "%*"=="" (
	for /f "tokens=1,2,3 delims={}" %%0 in ('echo %*') do (
		call :Display "ASN Network:		" "%%~0"
		call :Display "ASN:			" "%%~1"
		call :Display "ISP:			" "%%~2"
		echo.
	)
)
exit /b

rem =====
rem Format data strings to prevent internal errors and improve data display
rem =====

:Format_String
set DATA=
set STRING=%*
set STRING=!STRING:,,=,\Null\,!
set STRING=!STRING:,,=,\Null\,!
set STRING=!STRING:,,=,\Null\,!
set STRING=!STRING:^&=\Ampersand\!
call :Format_SubStrings !STRING!
exit /b

:Format_SubStrings
if "%~1"=="" (
	set STRING=
	exit /b
)
set STRING=%~1
set STRING=!STRING:^"^"=\DoubleQuote\!
set STRING=!STRING:^"^"=\DoubleQuote\!
set STRING=!STRING:^"^"=\DoubleQuote\!
set STRING=!STRING:^,=\Comma\!
set STRING=!STRING:^(=\OpenParantheses\!
set STRING=!STRING:^)=\CloseParantheses\!
set DATA=!DATA!{!STRING!}
shift
goto Format_SubStrings

rem =====
rem Reinterpret punctuation and display data
rem =====

:Display
if not "%~2"=="" if not "%~2"=="\Null\" (
	set DATA=%~2
	set DATA=!DATA:\Ampersand\=^&!
	set DATA=!DATA:\DoubleQuote\=^"!
	set DATA=!DATA:\Comma\=^,!
	set DATA=!DATA:\OpenParantheses\=^(!
	set DATA=!DATA:\CloseParantheses\=^)!
	echo %~1!DATA!
)
exit /b

rem =====
rem Help
rem =====

:Help
echo ----- WAN Data -----
echo WAN:			Target IP's parent wide area network
echo Continent:		Continent on which the target IP resides
echo Country:		Country in which the target IP resides
echo Subdivisin 1:		Major subdivision in which the target IP resides
echo Subdivisin 2:		Minor subdivision in which the target IP resides
echo City:			City in which the target IP resides
echo Metro Code:		Metro code to the target IP's surrounding area
echo Time Zone:		Time zone of the target IP's surrounding area
echo Registered Country:	Country to which the target IP is registered
echo				Displayed as: Country, Continent (Time zone)
echo Represented Country:	Foreign national representation possessing the IP
echo				Displayed as: Country, Continent (Time zone)
echo Known Proxy:		Does the target IP host a known proxy server ^(Yes/No^)
echo Post Code:		Post code to the target IP's surrounding area
echo Google Maps:		Google Maps link to view the IP's approximate location
echo Accuracy:		Approximate accuracy of the target IP's location results
echo.
echo ----- ASN Data -----
echo ASN Network:		Network to which the target IP's covering ASN spans
echo ASN:			Autonomous system number covering the target IP
echo ISP:			The organization/ISP in control of the target IP's ASN
echo.
echo ----- Other Data -----
echo Known Tor Exit:		Does the target IP host a known Tor exit node ^(Yes/No^)
exit /b