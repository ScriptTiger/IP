@echo off

rem =====
rem For more information on ScriptTiger and more ScriptTiger scripts visit the following URL:
rem https://scripttiger.github.io/
rem Or visit the following URL for the latest information on this ScriptTiger script:
rem https://github.com/ScriptTiger/IP
rem =====

echo Initializing...

rem =====
rem Environmental setup
rem =====

setlocal ENABLEDELAYEDEXPANSION
set Count=1
for /f "tokens=3" %%0 in (
	'netsh interface ip show config "Ethernet 2" ^| findstr "IP Address:"'
) do set IP=%%0
for /f "tokens=3" %%0 in (
	'netsh interface ip show config "Ethernet 2" ^| findstr "Default Gateway:"'
) do set GATEWAY=%%0

rem =====
rem Initialize and count indices
rem =====

set Index=0
for /f "tokens=1,2" %%0 in (
	'echo L0 127.0.0.1^
&	echo L0 localhost^
&	echo Eth0 !IP!^
&	echo Gateway !GATEWAY!^
&	echo Google google.com'
) do (
	set /a Index=!Index!+1
	set Index_!Index!_=%%0,%%1,0,0,0,0	,0
)

rem =====
rem Save current time
rem =====

set Time=%date% @ %time%

rem =====
rem Begin main loop
rem =====

for /l %%0 in () do (

rem =====
rem Recurse indices
rem 1.) name, 2.) ip/url, 3.) success, 4.) average ms, 5.) percent, 6.) display, 7.) ms/*
rem =====

	for /f "tokens=1,2,3,4,5,7 delims==," %%a in (
		'set index_'
	) do (
		set Success=%%d
		set AverageMS=%%e

rem =====
rem Time display on unsuccessful ping
rem =====

		set MSDisplay=%%f
		set TimeMS=*

rem =====
rem Ping host
rem =====

		for /f "tokens=1,2,4,8,10 delims==<m " %%0 in (
			'ping -l 0 -n 1 -w 300 -4 %%c ^| findstr /b /r "^Reply from bytes time TTL"'
		) do (

rem =====
rem Calculate statistics on successful ping
rem =====

			if "%%0 %%1 %%2 %%4"=="Reply fro bytes TTL" (
				if %%3==1 set TimeMS=^<1
				if %%3 gtr 1 set TimeMS=%%3
				set /a Success=!Success!+1
				set /a AverageMS=^(^(!AverageMS!*^(!Success!-1^)^)+%%300^)/!Success!
				if !AverageMS!==100 set MSDisplay=^<1	
				if !AverageMS! gtr 100 (
					set MSDisplay=~!AverageMS:~,-2!.!AverageMS:~-2!
					if !AverageMS! lss 1000 set MSDisplay=!MSDisplay!	
				)
			)
		)

rem =====
rem Calculate remaining statistics
rem =====

		set /a Percent=^(!Success!*100^)/!Count!

rem =====
rem Save index
rem =====

		set %%a=%%b,%%c,!Success!,!AverageMS!,!Percent!,!MSDisplay!,!TimeMS!
	)

rem =====
rem Display
rem =====

	cls
	rem echo Statistics started on %Time%
	rem echo Percents and averages based on a sample of !Count! pings
	for /f "tokens=2,3,6,7,8 delims==," %%0 in (
		'set index_ ^| findstr "Index_[0-9]_"^
&		set index_ ^| findstr "Index_[0-9][0-9]_"'
	) do echo %%0	: %%2%%	@ %%3	[%%4	%%1]

rem =====
rem Increment count before reiterating main loop
rem =====

	set /a Count=!Count!+1
	timeout /t 1 /nobreak > nul
)