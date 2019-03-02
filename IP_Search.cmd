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
rem Unattended mode parameters
rem =====

set UM=0
if "%~1"=="csv" (
	set UM=1
	if not "%~3"=="" set CSV=%~3
)

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
set LANG=%LANG:csv=en%
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

if %UM%==0 echo ----- WAN Data -----
call :Find "%FINDSTR%" "%CITY4%" CITY

rem =====
rem Search ASN data for any of the possible networks
rem =====

if %UM%==0 echo ----- ASN Data -----
call :Find "%FINDSTR%" "%ASN4%" ASN

rem =====
rem Search Tor exit nodes to see if the IP is listed
rem =====

if %UM%==0 echo ----- Other Data -----
set TOR=0
for /f %%0 in ('findstr /b /l /c:"ExitAddress %IP% " "%TOR4%"') do set TOR=1

rem =====
rem Output either the finished CSV output or display Tor results
rem =====

if %UM%==1 (
	call :Output "" "1:%IP%,%UMSTR%,20:%TOR%"
	exit /b
)

set TOR=%TOR:0=No%
set TOR=%TOR:1=Yes%
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
if not "%*"=="" (
	for /f "tokens=1,2,3,4,5,7,8,9,10 delims={}" %%0 in ('echo %*') do (
		if %UM%==0 (
			call :Output "WAN:			" "%%~0"
			if not "%%~1"=="\Null\" call :Resolve_City %%~1
			if not "%%~2"=="\Null\" call :Resolve_Country %%~2 Registered
			if not "%%~3"=="\Null\" call :Resolve_Country %%~3 Represented
			if "%%~4"=="0" (call :Output "Known Proxy:		" "No") else call :Output "Known Proxy:		" "Yes"
			call :Output "Post Code:		" "%%~5"
			SET URL=
			if not "%%~6"=="\Null\" if not "%%~7"=="\Null\" (
				set URL=https://www.google.com/maps/@%%~6,%%~7,6z
				call :Output "Google Maps:		" "!URL!"
			)
			if not "%%~8"=="" call :Output "Accuracy:		" "%%~8 km"
			echo.
		) else (
			set UMSTR=2:%%~0,3:%%~1,4:%%~2,5:%%~3,6:%%~4,7:%%~5,8:%%~6,9:%%~7,10:%%~8
			call :Resolve_City_CSV %%~1
		)
	)
)
exit /b

rem =====
rem Resolve and break down city strings
rem =====

:Resolve_City
for /f "tokens=3* delims=," %%a in ('findstr /b /l "%~1," "%LANG%"') do (
	call :Format_String %%b
	for /f "tokens=1,3,5,7,8,9,10,11 delims={}" %%0 in ('echo !DATA!') do (
		call :Output "Continent:		" "%%~0"
		call :Output "Country:		" "%%~1"
		call :Output "Subdivisin 1:		" "%%~2"
		call :Output "Subdivisin 2:		" "%%~3"
		call :Output "City:			" "%%~4"
		call :Output "Metro Code:		" "%%~5"
		call :Output "Time Zone:		" "%%~6"
		set DATA=%%~7
		set DATA=!DATA:0=No!
		set DATA=!DATA:1=Yes!
		Call :Output "EU:			" "!DATA!"
	)
)
exit /b

rem =====
rem Resolve city CSV string
rem =====

:Resolve_City_CSV
for /f "tokens=2* delims=," %%a in ('findstr /b /l "%~1," "%LANG%"') do (
	call :Format_String %%b
	for /f "tokens=1,3,5,7,10,11,12 delims={}" %%0 in ('echo !DATA!') do (
		set UMSTR=%UMSTR%,11:%%0,12:%%1,13:%%2,14:%%3,15:%%4,16:%%5,17:%%6
	)
)

exit /b

rem =====
rem Resolve and break down country strings
rem =====

:Resolve_Country
for /f "tokens=3* delims=," %%a in ('findstr /b /l "%~1," "%LANG%"') do (
	call :Format_String %%b
	for /f "tokens=1,3,10 delims={}" %%0 in ('echo !DATA!') do (
		set DATA=%%~1, %%~0
		if not "%%~2"=="\Null\" set DATA=!DATA! \OpenParantheses\%%~2\CloseParantheses\
		call :Output "%~2 Country:	" "!DATA!"
	)
)
exit /b

rem =====
rem Display matching ASN data
rem =====

:ASN
if not "%*"=="" (
	for /f "tokens=1,2,3 delims={}" %%0 in ('echo %*') do (
		if %UM%==0 (
			call :Output "ASN Network:		" "%%~0"
			call :Output "ASN:			" "%%~1"
			call :Output "ISP:			" "%%~2"
			echo.
		) else set UMSTR=%UMSTR%,18:%%~0,19:%%~1
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
rem Reinterpret punctuation and output data
rem =====

:Output
if not "%~2"=="" if not "%~2"=="\Null\" (
	set DATA=%~2
	set DATA=!DATA:\Ampersand\=^&!
	set DATA=!DATA:\DoubleQuote\=^"!
	set DATA=!DATA:\Comma\=^,!
	set DATA=!DATA:\OpenParantheses\=^(!
	set DATA=!DATA:\CloseParantheses\=^)!
	if %UM%==1 set DATA=!DATA:\Null\=!
	if "%CSV%"=="" (
		echo %~1!DATA!
	) else (
		if not exist "%CSV%" echo ip_address,city_network,geoname_id,registered_country_geoname_id,represented_country_geoname_id,is_anonymous_proxy,postal_code,latitude,longitude,accuracy_radius,continent_code,country_iso_code,subdivision_1_iso_code,subdivision_2_iso_code,metro_code,time_zone,is_in_european_union,asn_network,autonomous_system_number,is_tor_node>"%CSV%"
		echo %~1!DATA!>>"%CSV%"
	)
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
echo EU:			Is the target IP in the EU ^(Yes/No^)
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
echo ISP:			ISP controlling the target IP's covering ASN
echo.
echo ----- Other Data -----
echo Known Tor Exit:		Does the target IP host a known Tor exit node ^(Yes/No^)
exit /b