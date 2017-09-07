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
set NETCALC=%~dp0Network_Calc.cmd

set INTERACTIVE=1

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

if "%~2"=="" (set /p IP=IP: ) else (
	set IP=%~2
	set INTERACTIVE=0
)

set FINDSTR=
for /l %%0 in (0,1,32) do (
	for /f %%a in ('%NETCALC% /id %IP%/%%0') do set FINDSTR=!FINDSTR!%%a, 
)

set CITY=
call :Find "%FINDSTR%" "%CITY4%" CITY

set ASN=
call :Find "%FINDSTR%" "%ASN4%" ASN

if not "!CITY!"=="" (
	for /f "tokens=2 delims=," %%a in ('echo !CITY!') do set CITY=%%a
	for /f "tokens=2* delims=," %%a in ('findstr /b "!CITY!" "%LANG%"') do set CITY=%%b
	echo City:	!CITY!
) else echo No City Data found for this Public IP

if not "!ASN!"=="" (
	for /f "tokens=2* delims=," %%a in ('echo !ASN!') do set ISP=%%~b
	for /f "tokens=2 delims=," %%a in ('echo !ASN!') do set ASN=%%a
	echo ASN:	!ASN!
	echo ISP:	!ISP!
) else echo No ASN Data found for this Public IP

if %INTERACTIVE%==1 pause

exit /b

:Find
for /f "tokens=*" %%0 in ('findstr /b /l "%~1" "%~2"') do set %~3=%%0
exit /b