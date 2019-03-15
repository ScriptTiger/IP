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
if /i "%~1"=="-help" goto Help
if /i "%~1"=="--help" goto Help
if "%~1"=="?" goto Help
if "%~1"=="/?" goto Help
if "%~1"=="-?" goto Help
if "%~1"=="--?" goto Help

rem =====
rem Environmental setup
rem =====

setlocal ENABLEDELAYEDEXPANSION

set CALC=%~dp0Script_Calc.cmd

rem =====
rem Convert to string using decimal
rem =====

if "%1"=="/s" (
	call :DecToStr DEC %2 %3
	echo !DEC!
	exit /b
)

rem =====
rem Convert to decimal using string
rem =====

if "%1"=="/d" (
	call :StrToDec STR %2 %3
	if "!STR!"=="0x80000000" set STR=-2147483648
	if not "%2"=="/r" for /f %%0 in ('!CALC! /32bit !STR!') do set STR=%%0
	echo !STR!
	exit /b
)

rem =====
rem Convert to network ID using IP/CIDR
rem =====

if "%1"=="/id" (
	for /f "tokens=1,2,3,4,5 delims=/" %%0 in ("%2") do (
		call :CIDRToRMask %%1
		call :XOR MASK !RMASK!
		call :AND ID %%0 !MASK!
		echo !ID!/%%1
	)
	exit /b
)

rem =====
rem Interactive mode
rem =====

if not "%1"=="" (
	set IM=0
	goto Calc
) else set IM=1

:Input
set /p IP=IP address: || exit /b
set /p MASK=Subnet Mask: || exit /b
call :Calc !IP! !MASK!
exit /b

rem =====
rem Calculate network information based on IP and CIDR or mask
rem =====

:Calc
echo.
if "%2"=="" set CIDR=1
for /f "tokens=1,2 delims=/ " %%0 in ("%1 %2") do (
	if "!CIDR!"=="1" (
		set CIDR=%%1
		call :CIDRToRMask %%1
		call :XOR MASK !RMASK!
		call :AND ID %%0 !MASK!
	) else (
		set MASK=%%1
		call :XOR RMASK %%1
		call :MaskToCIDR %%1
		call :AND ID %%0 %%1
	)
	call :OR BCAST %%0 !RMASK!
	call :StrToDec DIP %%0
	for /f %%a in ('!CALC! /32bit !DIP!') do set DIP=%%a
	call :StrToDec HOSTS !RMASK!
	if !HOSTS! leq 1 (
		set /a HOSTS=!HOSTS!+1
		set START=!ID!
		set END=!BCAST!
		if !HOSTS!==2 echo Note:	This point-to-point network does not contain a broadcast address.&echo		This may cause problems for some devices.
		if !HOSTS!==1 echo Note:	This is a unicast address and not a network.
	) else (
		set /a HOSTS=!HOSTS!-1
		call :StrToDec START !ID!
		set /a START=!START!+1
		call :DecToStr START !START!
		call :StrToDec END !BCAST!
		set /a END=!END!-1
		call :DecToStr END !END!
	)
	if "!DIP!"=="0x80000000" set DIP=2147483648
	echo %%0 ^(!DIP!^) / !MASK! ^(!RMASK!^):
	echo !ID!/!CIDR! - !BCAST!
	echo !START! - !END! ^(!HOSTS! usable IPs^)
)
if %IM%==1 pause
exit /b

rem =====
rem Dec<->Str conversions
rem enable support for reverse (/r) IPs
rem =====

:DecToStr
if "%2"=="/r" shift
if "%2"=="-2147483648" (
	set /a SubStr1="128"
	set /a SubStr2="0"
	set /a SubStr3="0"
	set /a SubStr4="0"
) else (
	set /a SubStr1="(%2>>24)&0xff"
	set /a SubStr2="(%2>>16)&0xff"
	set /a SubStr3="(%2>>8)&0xff"
	set /a SubStr4="%2&0xff"
)
if "%1"=="/r" (
	set %0=!SubStr4!.!SubStr3!.!SubStr2!.!SubStr1!
) else (
	set %1=!SubStr1!.!SubStr2!.!SubStr3!.!SubStr4!
)
exit /b

:StrToDec
if "%2"=="/r" shift
call :StrToSubStr %2
if "%1"=="/r" (
	set /a %0="!SubStr1!+(!SubStr2!<<8)+(!SubStr3!<<16)+(!SubStr4!<<24)"
) else (
	if "%2"=="128.0.0.0" (
		set %1=0x80000000
	) else (
		set /a %1="(!SubStr1!<<24)+(!SubStr2!<<16)+(!SubStr3!<<8)+!SubStr4!"
	)
)
exit /b

rem =====
rem CIDR<->(R)Mask conversions
rem =====

:CIDRToRMask
set RMASK=0
set /a RCIDR=32-%1
for /l %%a in (1,1,!RCIDR!) do set /a RMASK="(!RMASK!<<1)+1"
call :DecToStr RMASK !RMASK!
exit /b

:MaskToCIDR
call :StrToSubStr %1
set CIDR=0
for %%0 in (!SubStr1! !SubStr2! !SubStr3! !SubStr4!) do (
	for /l %%a in (0,1,7) do (
	set /a OCT="0x100-(1<<%%a)"
	if %%0==!OCT! set /a CIDR=!CIDR!+8-%%a
	)
)
exit /b

rem =====
rem Convert an IP string to 4 octet substrings for individual calculation
rem =====

:StrToSubStr
for /f "tokens=1,2,3,4 delims=." %%0 in ("%1") do (
	set SubStr1=%%0
	set SubStr2=%%1
	set SubStr3=%%2
	set SubStr4=%%3
)
exit /b

rem =====
rem Bitwise calculations
rem =====

:AND
:OR
:XOR
call :StrToDec Str %2
if "%0"==":XOR" (
	set /a Str="!Str!^^0xffffffff"
) else (
	call :StrToDec Str2 %3
	if "%0"==":AND" (set /a Str="!Str!&!Str2!") else (set /a Str="!Str!|!Str2!")
)
call :DecToStr %1 !Str!
exit /b

rem =====
rem Help
rem =====

:Help
echo /d [/r] ^<X^>		Retrieve decimal format using X.X.X.X format
echo /s [/r] ^<X^>		Retrieve X.X.X.X format using decimal format
echo /id ^<X.X.X.X/X^>		Retrieve network ID using X.X.X.X/CIDR format
echo ^<X.X.X.X^>[/X / X.X.X.X]	Retrieve network information
exit /b