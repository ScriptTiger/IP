@echo off
setlocal ENABLEDELAYEDEXPANSION
set bdat=C:\Users\user\Desktop\scripts\logs\bits.dat
set label=%1
if not "%3"=="" goto !label:~1!
if "!label:~,1!"=="/" set external=1&shift&goto !label:~1!

rem The default operation of this script is to add two numbers
rem Subtraction is thus treated as addition by adding a positive with a negative
rem Script_Calc 1 1 results in 2
rem Script_Calc 1 -1 results in 0
:add
call :detect_sign "%1" sign1
call :detect_sign "%2" sign2
call :remove_sign "%1" string1
call :remove_sign "%2" string2
set digit4=0
set string3=
if "!sign1!"=="!sign2!" (
	call :add_calc
) else (
	call :subtract_calc
)
if "%3"=="" (
	echo !string3!
) else (
	set %3=!string3!
)
exit /b

rem Stacked bitwise function
rem Converts all numbers to hexidecimal first to keep bit integrity
rem Calculates 8 hexidecimal numbers at a time
rem Outputs in hexidecimal
:and
:or
:xor
call :dec2hex "%2" bitwise1
call :dec2hex "%3" bitwise2
set bitwise1=!bitwise1:~2!
set bitwise2=!bitwise2:~2!
set bitwise4=
:bin_loop
call :shift_right "!bitwise1!" bitwise1 oct1
call :shift_right "!bitwise2!" bitwise2 oct2
if "%1"=="/and" set /a bitwise3="0x!oct1!&0x!oct2!"
if "%1"=="/or" set /a bitwise3="0x!oct1!|0x!oct2!"
if "%1"=="/xor" set /a bitwise3="0x!oct1!^^0x!oct2!"
call :dec2hex !bitwise3! bitwise3
set bitwise4=!bitwise3:~2!!bitwise4!
if "!bitwise1!"=="" if "!bitwise2!"=="" (
	call :zeros !bitwise4! bitwise4
	echo 0x!bitwise4!
	exit /b
)
goto bin_loop

rem Sign detection function to designate positive or negative
:detect_sign
set string=%~1
if "!string:~,1!"=="-" (set %2=-) else (set %2=+)
exit /b

rem Sign stripping function
:remove_sign
set string=%~1
if "!string:~,1!"=="-" (set %2=!string:~1!) else (set %2=!string!)
exit /b

rem Positive on positive and nagative on negative addition calculations
:add_calc
call :shift_right "!string1!" string1 oct1
call :shift_right "!string2!" string2 oct2
call :zeros !oct1! oct1
call :zeros !oct2! oct2
set /a oct3=100000000+!oct1!+!oct2!+!digit4!
set string3=!oct3:~-8!!string3!
if !oct3! geq 200000000 (set digit4=1) else (set digit4=0)
if "!string1!"=="" if "!string2!"=="" if "!digit4!"=="0" (
	call :zeros !string3! string3
	if "!sign1!"=="-" set string3=-!string3!
	exit /b
)
goto add_calc

rem Positive on negative subtraction calculations
:subtract_calc
call :eval !string1! !string2! string

if "!string!"=="eq" (
	set string3=0
	exit /b
)

if "!string!"=="gtr" (
	set sign=!sign1!
) else (
	set sign=!sign2!
	set string=!string1!
	set string1=!string2!
	set string2=!string!
)

:subtract_loop
call :shift_right "!string1!" string1 oct1
call :shift_right "!string2!" string2 oct2
call :zeros !oct1! oct1
call :zeros !oct2! oct2
set /a oct3=100000000+!oct1!-!oct2!-!digit4!
if !oct3! lss 100000000 (set /a oct3=!oct3!+100000000&set digit4=1) else (set digit4=0)
set string3=!oct3:~-8!!string3!
if "!string1!"=="" if "!string2!"=="" (
	call :zeros !string3! string3
	if "!sign!"=="-" set string3=-!string3!
	exit /b
)
goto subtract_loop

rem Evaluate two numbers
rem This function is a necessity to replace native evaluations for "if X gtr/lss/eq Y" for numbers larger than 32 bits
rem For "or equal to" evaluations, just use "if X not gtr/lss/eq Y" and pick the one you are NOT looking for of the three choices
:eval
if "%1"=="%2" (
	call :return eq %3
	exit /b
)

if "!sign1!"=="" if "!sign2!"=="" (
	call :detect_sign "%1" sign1
	call :detect_sign "%2" sign2

	if not "!sign1!"=="!sign2!" (
		if "!sign1!"=="-" (
			call :return lss %3
		) else (
			call :return gtr %3
		)
		exit /b
	)
)

call :count_digits %1 count1
call :count_digits %2 count2

if not !count1!==!count2! (
if !count1! gtr !count2! (
	call :return gtr %3
) else (
	call :return lss %3)
	exit /b
)

call :sort_digits %1 %2

if "!string!"=="%1" (
	call :return gtr %3
) else (
	call :return lss %3
)
exit /b

rem Return function to handle interactive or scripted mode
:return
if "%2"=="" (echo %1) else (set %2=%1)
exit /b

rem Count how many characters in a string
:count_digits
set count=
call :expand_string %1 string
for %%0 in (!string!) do set /a count=!count!+1
set %2=!count!
exit /b

rem Sort automatically evaluates strings character by character going from left to right
rem Useful for evaluating numbers of the same character length quickly
:sort_digits
for /f %%0 in ('^(echo %1^&echo %2^) ^| sort') do set string=%%0
exit /b

rem Separate number characters into substrings to iterate character-to-character calculations in for loops
:expand_string
set string=%1
set string=!string:0= 0 !
set string=!string:1= 1 !
set string=!string:2= 2 !
set string=!string:3= 3 !
set string=!string:4= 4 !
set string=!string:5= 5 !
set string=!string:6= 6 !
set string=!string:7= 7 !
set string=!string:8= 8 !
set string=!string:9= 9 !
set string=!string:A= A !
set string=!string:B= B !
set string=!string:C= C !
set string=!string:D= D !
set string=!string:E= E !
set string=!string:F= F !
set %2=!string!
exit /b

rem Condense an expanded number back to a single string
:condense_string
set string=%~1
set string=!string: =!
set %2=!string!
exit /b

rem Segments a string to be calculated in groups of 8 characters at a time
:shift_right
if "%~1"=="" (
	set %3=0
) else (
	set string=%~1
	if "!string:~,-8!"=="" (
		set %~3=!string!
		set %~2=
	) else (
		set %3=!string:~-8!
		set %2=!string:~,-8!
	)
)
exit /b

rem Strip leading zeros
rem Example: 010 -> stripped -> 10 -> reversed -> 01 -> stripped -> 1
:zeros
if "%1"=="0" exit /b
set string=%1
:zeros_loop
if "!string:~,1!"=="0" if not "!string!"=="0" (
	set string=!string:~1!
	goto zeros_loop
)
set %2=!string!
exit /b

rem Reverse an expanded number to calculate substring characters backwards
:reverse_expanded
set string=
for %%0 in (%~1) do set string=%%0 !string!
set %2=!string!
exit /b

rem Convert decimal to hexidecimal
:dec2hex
if !external!==1 set external=2
call :dec2bin %1 hex
call :bin2hex !hex! hex
if !external!==2 (echo !hex!) else (set %2=!hex!)
exit /b

rem Convert binary to hexidecimal
:bin2hex
if "%1"=="" (
	set %2=0x0
	exit /b
)
set string=%1
set hex=
:bin2hex_loop
if "!string:~,-4!"=="" (
	set nibble=!string!
	set string=
) else (
	set nibble=!string:~-4!
	set string=!string:~,-4!
)

if "!nibble!"=="0" set nibble=0
if "!nibble!"=="1" set nibble=1

if "!nibble!"=="00" set nibble=0
if "!nibble!"=="01" set nibble=1
if "!nibble!"=="10" set nibble=2
if "!nibble!"=="11" set nibble=3

if "!nibble!"=="000" set nibble=0
if "!nibble!"=="001" set nibble=1
if "!nibble!"=="010" set nibble=2
if "!nibble!"=="011" set nibble=3
if "!nibble!"=="100" set nibble=4
if "!nibble!"=="101" set nibble=5
if "!nibble!"=="110" set nibble=6
if "!nibble!"=="111" set nibble=7

if "!nibble!"=="0000" set nibble=0
if "!nibble!"=="0001" set nibble=1
if "!nibble!"=="0010" set nibble=2
if "!nibble!"=="0011" set nibble=3
if "!nibble!"=="0100" set nibble=4
if "!nibble!"=="0101" set nibble=5
if "!nibble!"=="0110" set nibble=6
if "!nibble!"=="0111" set nibble=7
if "!nibble!"=="1000" set nibble=8
if "!nibble!"=="1001" set nibble=9
if "!nibble!"=="1010" set nibble=A
if "!nibble!"=="1011" set nibble=B
if "!nibble!"=="1100" set nibble=C
if "!nibble!"=="1101" set nibble=D
if "!nibble!"=="1110" set nibble=E
if "!nibble!"=="1111" set nibble=F

set hex=!nibble!!hex!
if "!string!"=="" (
	set %2=0x!hex!
	exit /b
)
goto bin2hex_loop

rem Convert hexidecimal to binary
:hex2bin
if "%1"=="" (
	set %2=0
	exit /b
)

set string=%1
set string=!string:0x=!
set string=!string:0=0000!
set string=!string:1=0001!
set string=!string:2=0010!
set string=!string:3=0011!
set string=!string:4=0100!
set string=!string:5=0101!
set string=!string:6=0110!
set string=!string:7=0111!
set string=!string:8=1000!
set string=!string:9=1001!
set string=!string:A=1010!
set string=!string:B=1011!
set string=!string:C=1100!
set string=!string:D=1101!
set string=!string:E=1110!
set string=!string:F=1111!
set %2=!string!
exit /b

rem If a 32-bit number is negative, this will break it out to be a true 32-bit number with no bit for sign control
:32bit
call :detect_sign "%1" sign
call :remove_sign "%1" dec
if "!sign!"=="-" (call :add 4294967296 %~1 dec)
echo !dec!
exit /b

rem If a 32-bit positive number takes up 32 bits, this converts it to a 32-bit negative with sign control
:32bitp
set dec=%1
call :eval %1 2147483648 string
if not "!string!"=="lss" (call :add -4294967296 %~1 dec)
echo !dec!
exit /b

rem Converts decimal to binary
:dec2bin
if "%1"=="0" (
	if "!external!"=="1" (echo 0) else (set %2=0)
	exit /b
)

call :detect_sign "%1" sign
call :remove_sign "%1" dec
if "!sign!"=="-" (call :add 4294967296 %~1 dec)

rem Load default 32-bit number set

set bits=2147483648
set bit=2147483648

rem Load 64-bit number set if the number is larger than 32 bits

call :eval !dec! 2147483648 string
if "!string!"=="gtr" (
	set bits=9223372036854775808 4611686018427387904 2305843009213693952 1152921504606846976 576460752303423488 288230376151711744 144115188075855872 72057594037927936 36028797018963968 18014398509481984 9007199254740992 4503599627370496 2251799813685248 1125899906842624 562949953421312 281474976710656 140737488355328 70368744177664 35184372088832 17592186044416 8796093022208 4398046511104 2199023255552 1099511627776 549755813888 274877906944 137438953472 68719476736 34359738368 17179869184 8589934592 4294967296 !bits!
	set bit=9223372036854775808

rem Load 128-bit number set if the number is larger than 64 bits

	call :eval !dec! 9223372036854775808 string
	if "!string!"=="gtr" (
		set bits=170141183460469231731687303715884105728 85070591730234615865843651857942052864 42535295865117307932921825928971026432 21267647932558653966460912964485513216 10633823966279326983230456482242756608 5316911983139663491615228241121378304 2658455991569831745807614120560689152 1329227995784915872903807060280344576 664613997892457936451903530140172288 332306998946228968225951765070086144 166153499473114484112975882535043072 83076749736557242056487941267521536 41538374868278621028243970633760768 20769187434139310514121985316880384 10384593717069655257060992658440192 5192296858534827628530496329220096 2596148429267413814265248164610048 1298074214633706907132624082305024 649037107316853453566312041152512 324518553658426726783156020576256 162259276829213363391578010288128 81129638414606681695789005144064 40564819207303340847894502572032 20282409603651670423947251286016 10141204801825835211973625643008 5070602400912917605986812821504 2535301200456458802993406410752 1267650600228229401496703205376 633825300114114700748351602688 316912650057057350374175801344 158456325028528675187087900672 79228162514264337593543950336 39614081257132168796771975168 19807040628566084398385987584 9903520314283042199192993792 4951760157141521099596496896 2475880078570760549798248448 1237940039285380274899124224 618970019642690137449562112 309485009821345068724781056 154742504910672534362390528 77371252455336267181195264 38685626227668133590597632 19342813113834066795298816 9671406556917033397649408 4835703278458516698824704 2417851639229258349412352 1208925819614629174706176 604462909807314587353088 302231454903657293676544 151115727451828646838272 75557863725914323419136 37778931862957161709568 18889465931478580854784 9444732965739290427392 4722366482869645213696 2361183241434822606848 1180591620717411303424 590295810358705651712 295147905179352825856 147573952589676412928 73786976294838206464 36893488147419103232 18446744073709551616 !bits!
		set bit=170141183460469231731687303715884105728

rem If the number is higher than 128 bits, check if there is a cache file with a higher number set
rem If the cache file exists, load the number set

		call :eval !dec! 170141183460469231731687303715884105728 string
		if "!string!"=="gtr" (
			if exist !bdat! (
				set /p bits=<!bdat!
				for /f %%0 in (!bdat!) do set bit=%%0
			) else (
				set bit=1
				set bits=1
			)
		) else (
			goto dec2bin_return
		)
	)
)

rem If the number set is still not high enough, calculate it real time
rem Save the number set in the cache for later to speed up the operaton next time
:dec2bin_loop
call :eval !dec! !bit! string
if "!string!"=="gtr" (
	call :add !bit! !bit! bit
	set bits=!bit! !bits!
	if not !cache!==1 set cache=1
	goto dec2bin_loop
)
if !cache!==1 (
	echo !bits!>!bdat!
	set cache=
)

rem Begin evaluating input number against number set to calculate bits
:dec2bin_return
set bin=

rem Loop to calculate numbers 32 bits and higher

for %%0 in (!bits!) do (
	call :eval !dec! %%0 string
	if "!string!"=="lss" (set bin=!bin!0) else (set bin=!bin!1&call :add !dec! -%%0 dec)
)

rem Loop to calculate 31 bits and lower

for /l %%0 in (30,-1,0) do (
	set /a bit="!dec!&(1<<%%0)"
	if !bit!==0 (set bin=!bin!0) else (set bin=!bin!1)
)

rem Clean up leading zeros and return result

call :zeros !bin! bin
if "!external!"=="1" (echo !bin!) else (set %2=!bin!)
exit /b