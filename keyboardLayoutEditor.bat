@echo off
if defined PID if exist "!sst.dir!\temp\kernelPipe" (
%=% call systemb-dialog.bat 5 3 44 5 "keyboardLayoutEditor	classic"^
%=====% "l2=  This program is not a Shivtanium application."^
%=====% 52 3 7 " Close "
%=% exit /b
)

if not defined \e for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"
cd "%~dp0"
setlocal enableDelayedExpansion
if /I "%~1"=="/p" goto setupKeys
if /I "%~1"=="/f" goto setupFnKeys
if /I "%~1"=="/d" goto setupDpKeys
if "%~1"==":main" goto main
if "%~1"==":timer" goto timer
if not exist getInput64.dll (
	echo File not found: getInput64.dll
	pause
	exit /b 1
)

for /f "tokens=1 delims==" %%a in ('set') do for /f "tokens=1 delims=._" %%c in ("%%~a") do (
	set "unload=True"
	for %%b in (
		ComSpec SystemRoot SystemDrive temp windir
		\n \e
		PROCESSOR
		NUMBER
		USERNAME
	) do if /i "%%~c"=="%%~b" set "unload=False"
	if "!unload!"=="True" set "%%a="
)
set PATHEXT=.COM;.EXE;.BAT
set "PATH=!windir!\System32;!windir!"
set unload=

if /I "%~1"=="/r" set recordingMode=true

set /a "rasterX=10, rasterY=18, noResize=1, modeW=114, modeH=20"
mode 74,7
chcp 65001 > nul
rundll32.exe getInput64.dll,inject
if not defined getInputInitialized (
	echo GetInput failed to initalize.
	pause
	exit 1
)
set rasterX= & set rasterY=
set ver=1.1.0
title Shivter's standard Batch Keyboard Layout Editor v!ver!
<nul set /p "=%\e%[48;5;255;38;2;;;m%\e%[2;3H%\e%[2J%\e%[?25lSet your font to a UTF-8 compatible font with a 4:7 or 5:9 size ratio.%\e%[3;3HRecommended: Raster 7x12 / 10x18, MxPlus IBM EGA 8x14 / EGA 9x16%\e%[4;3HDefault: Raster 10x18%\e%[6;3H"
choice /m "Use Raster 7x12"
if "!errorlevel!"=="1" (
	set /a "rasterX=7, rasterY=12"
)
<nul set /p "=%\e%[48;5;255;38;2;;;m%\e%[2;3H%\e%[2JPlease wait. . ."

if exist "%~1" (
	call :import "%~1"
) else (
	set "charset_L=                                                0123456789       abcdefghijklmnopqrstuvwxyz     0123456789☼+=-,/                                                                          ů%==%=%=%,-.´;                          ú¨)§"
	set "charset_U=                                                é+ěščřžýáí       ABCDEFGHIJKLMNOPQRSTUVWXYZ     0123456789☼+=-./                                                                          “%=%%%%=%¿_:ˇ°                          /'(‼"
	set "charset_A=                                     ←↑→↓       ˝~ˇˆ˘°˛`˙´        {&Đ€[]   łŁ }  \ đ  @|#                 ☼+=-./                                                                          $%==%¨%=%<☼>¸                           ÷¤×ß"
)

set "buttons="
(for /f "tokens=1-5 delims=;" %%1 in ('call "%~nx0" /p') do (
	set "buttons=!buttons! %%1"
	set /a "kb[%%1]BX=(kb[%%1]X=%%2+3)+(kb[%%1]W=%%4)-1, kb[%%1]BY=(kb[%%1]Y=%%3+3)+(kb[%%1]H=%%5)-1"
	set "kb[%%1]=!kb[%%1]:¤= !"
)
set bfrB=▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
set bfrT=▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
set "buttonsFN="
for /f "tokens=1-5 delims=;" %%1 in ('call "%~nx0" /f') do (
	set "buttonsFN=!buttonsFN! %%1"
	set /a "fk[%%1]BX=(fk[%%1]X=%%2+3)+%%4-1, fk[%%1]BY=(fk[%%1]Y=%%3+3)+%%5-1"
	set "fk[%%1]=%\e%[!fk[%%1]Y!;!fk[%%1]X!H%\e%[38;5;255m!bfrT:~0,%%4!%\e%[!fk[%%1]X!G"
	for /l %%a in (2 1 %%5) do (
		set "fk[%%1]=!fk[%%1]!%\e%[B%\e%[%%4X"
	)
	set "fk[%%1]=!fk[%%1]:¤= !"
)
set "buttonsDP="
for /f "tokens=1-5 delims=;" %%1 in ('call "%~nx0" /d') do (
	set "buttonsDP=!buttonsDP! %%1"
	set /a "dp[%%1]BX=(dp[%%1]X=%%2+3)+%%4-1, dp[%%1]BY=(dp[%%1]Y=%%3+3)+%%5-1"
	set "dp[%%1]=%\e%[!dp[%%1]Y!;!dp[%%1]X!H%\e%[38;5;255m!bfrT:~0,%%4!%\e%[!dp[%%1]X!G
	for /l %%a in (2 1 %%5) do (
		set "dp[%%1]=!dp[%%1]!%\e%[B%\e%[!dp[%%1]X!G%\e%[%%4X"
	)
	set "dp[%%1]=!dp[%%1]:¤= !"
)

set "keys= "
set "currentClick=!click!"
)

call "%~nx0" :timer | call "%~nx0" :main
exit /b
:main
rundll32.exe getInput64.dll,inject
if not defined getInputInitialized (
	echo GetInput failed to initalize.
	pause
	exit 1
)
mode !modeW!,!modeH!
call :redraw
for /l %%# in () do (
	set /p "="
	if not defined recordingMode (
		set "oldClick=!currentClick!"
		set "currentClick=!click!"
		set "mouseX=!mouseXpos!"
		set "mouseY=!mouseYpos!"
	)
	set "keysPressedOld=!keys:-= !"
	set "keys= !keysPressed!"
	set "keys=!keys:-= !"
	set "keysRN=!keys!"
	for %%k in (!keysPressedOld!) do set "keysRN=!keysRN: %%k = !"

	set "keysRL=!keysPressedOld!"
	for %%k in (!keys!) do set "keysRL=!keysRL: %%k = !"

	if "!keysRL: 18 =!" neq "!keysRL: 16 =!" (
		call :redraw
	) else (for %%a in (!keysRL!) do (
		if defined kb[%%a] set /p "=%\e%[48;2;192;192;192;38;2;;;m!kb[%%a]!"
		if defined fk[%%a] set /p "=%\e%[48;2;128;128;192;38;2;;;m!fk[%%a]!"
		if defined dp[%%a] set /p "=%\e%[48;2;192;128;128;38;2;;;m!dp[%%a]!"
	))<nul
	if "!keysRN!" neq "!keysRN: 16 =!" (
		call :redraw U
		set "keysRN=!keys!"
	) else if "!keysRN!" neq "!keysRN: 18 =!" (
		call :redraw A
		set "keysRN=!keys!"
	)
	for %%a in (!keysRN!) do (
		if defined kb[%%a] set /p "=%\e%[48;2;128;128;128;38;2;;;m!kb[%%a]!"
		if defined fk[%%a] set /p "=%\e%[48;2;96;96;255;38;2;;;m!fk[%%a]!"
		if defined dp[%%a] set /p "=%\e%[48;2;255;96;96;38;2;;;m!dp[%%a]!"
	) < nul
	if "!oldClick!;!currentClick!"=="0;1" if "!mouseY!"=="1" (
		if !mouseX! geq 1 if !mouseX! leq 16 if !mouseX! leq 8 (
			<con set /p "importPath=%\e%[H%\e%[48;2;192;192;192;38;2;;;m%\e%[2KFull path: " && if not exist "!importPath!" (
				set /p "=%\e%[H%\e%[48;2;192;192;192;38;2;;;m%\e%[2KFile not found. Press any key to continue. . ."
				pause<con>nul
			) else call :import "!importPath!"
		) else if !mouseX! geq 10 (
			<con set /p "exportPath=%\e%[H%\e%[48;2;192;192;192;38;2;;;m%\e%[2KFull path: "
			if exist "!exportPath!" (
				set overwrite=
				<con set /p "overwrite=%\e%[H%\e%[48;2;192;192;192;38;2;;;m%\e%[2KOverwrite? (Y/n): "
				if /I "!overwrite!" neq "n" call :export
			) else call :export
		)
		call :redraw
	) else if !mouseY! gtr 2 if !mouseY! lss 26 if !mouseX! gtr 2 if !mouseX! lss 92 for %%a in (!buttons!) do if !mouseX! geq !kb[%%a]X! if !mouseX! leq !kb[%%a]BX! if !mouseY! geq !kb[%%a]Y! if !mouseY! leq !kb[%%a]BY! (
		set "rebind=%%a"
		set /a "rwX=(modeW-(rwW=32))/2+1, rwY=(modeH-(rwH=8))/2"
		<nul set /p "=%\e%[48;2;1;1;1;38;5;255m%\e%[!rwY!;!rwX!H%\e%[!rwW!X"
		for /l %%y in (2 1 !rwH!) do (
			<nul set /p "=%\e%[B%\e%[48;2;%%y;%%y;%%ym%\e%[!rwW!X"
		)
		set char=
		<con set /p "char=%\e%[!rwY!;!rwX!H%\e%[B Enter a character to%\e%[!rwY!;!rwX!H%\e%[2B bind to this key%\e%[!rwY!;!rwX!H%\e%[3B Only 1 character^! %\e%[!rwY!;!rwX!H%\e%[4B (' ' for unbound)%\e%[!rwY!;!rwX!H%\e%[6B %\e%[?25h" && (
			for %%c in (!charset!) do (
				set "temp=!charset_%%c:~1!"
				set "tempx=!charset_%%c!                                                                                                                                                                                                                                                                "
				set "char=!char:~0,1!"
				if "!char!" == "?" (       set "char=¿"
				) else if "!char!"=="^!" ( set "char=‼"
				) else if "!char!"=="*" (  set "char=☼"
				) else if !char! == ^^ (   set "char=ˆ"
				) else if !char! == ^" (   set "char=˝"
				) else if "!char!"=="	"  set "char= "
				set charset_%%c=!tempx:~0,%%a!!char!!temp:~%%a!
				set temp= & set tempx=
			)
		)
		call :redraw !charset!
	)
)
:redraw
set "buffer=%\e%[?25l%\e%[H%\e%[48;5;255;38;2;;;m%\e%[2J%\e%[48;2;192;192;192;38;2;;;m"
if not defined recordingMode set "buffer=!buffer! Import %\e%[C Export "
set charset=%1
if not defined charset set charset=L

for %%1 in (!buttons!) do (
	for %%w in (!kb[%%1]W!) do set "kb[%%1]=%\e%[!kb[%%1]Y!;!kb[%%1]X!H%\e%[38;5;255m!bfrT:~0,%%w!%\e%[B%\e%[%%wD%\e%[%%wX%\e%[38;2;;;m !charset_%charset%:~%%1,1!%\e%[!kb[%%1]X!G"
	for /l %%a in (3 1 !kb[%%1]H!) do set "kb[%%1]=!kb[%%1]!%\e%[B%\e%[!kb[%%1]W!X"
	set "buffer=!buffer!!kb[%%1]!"
)
set "buffer=!buffer!%\e%[48;2;128;128;192;38;2;;;m"
for %%a in (!buttonsFN!) do set "buffer=!buffer!!fk[%%a]!"
set "buffer=!buffer!%\e%[48;2;192;128;128;38;2;;;m"
for %%a in (!buttonsDP!) do set "buffer=!buffer!!dp[%%a]!"
echo=!buffer!%\e%[H
exit /b
:export
set /a "rwX=(modeW-(rwW=39))/2+1, rwY=(modeH-(rwH=8))/2"
set /p "=%\e%[48;2;1;1;1;38;5;255m%\e%[!rwY!;!rwX!H%\e%[!rwW!X"
for /l %%y in (2 1 !rwH!) do (
	set /p "=%\e%[B%\e%[48;2;%%y;%%y;%%ym%\e%[!rwW!X"
)
set format=1
<con set /p "format=%\e%[!rwY!;!rwX!H%\e%[B Export options%\e%[!rwX!G%\e%[2B Select a format: (Default = 1)%\e%[!rwX!G%\e%[B  1: Batch file with definitions (.bat)%\e%[!rwX!G%\e%[B  2: Batch Keyboard Layout Map (.bklm)%\e%[!rwX!G%\e%[B > "
if "!format!"=="1" ((
	for %%a in (L U A) do (
		echo @set "charset_%%a=!charset_%%a:%%=%%%%!"
	)
) > "!exportPath!" ) else (
	for %%a in (L U A) do echo !charset_%%a!
) > "!exportPath!"
if errorlevel 1 pause<con>nul
exit /b
:import
if /I "%~x1"==".bat" (
	call %1
) else if /I "%~x1"==".cmd" (
	call %1
) else (
	set /p "charset_L="
	set /p "charset_U="
	set /p "charset_A="
) < %1
exit /b
:setupKeys
echo=192;0;2;4;3
for /l %%a in (1 1 9) do (
	set /a "id=48+%%a, x=%%a*5"
	echo=!id!;!x!;2;4;3
)
echo=48;50;2;4;3
echo=187;55;2;4;3
echo=191;60;2;4;3

set "x=2"

for %%a in (81 87 69 82 84 90 85 73 79 80 219 221) do (
	set /a "x+=5"
	echo=%%a;!x!;5;4;3
)
set "x=3"
for %%a in (65 83 68 70 71 72 74 75 76 186 222 220) do (
	set /a "x+=5"
	echo=%%a;!x!;8;4;3
)
set "x=5"
for %%a in (89 88 67 86 66 78 77 188 190 189) do (
	set /a "x+=5"
	echo=%%a;!x!;11;4;3
)
echo=32;19;14;28;3

echo=111;96;2;4;3
echo=106;101;2;4;3
echo=109;106;2;4;3
echo=103;91;5;4;3
echo=104;96;5;4;3
echo=105;101;5;4;3
echo=100;91;8;4;3
echo=101;96;8;4;3
echo=102;101;8;4;3
echo=97;91;11;4;3
echo=98;96;11;4;3
echo=99;101;11;4;3
echo=96;91;14;9;3
echo=110;101;14;4;3
echo=107;106;5;4;6

exit /b
:setupFnKeys
echo=27;0;0;4;2
for /l %%a in (1 1 12) do (
	set /a "id=111+%%a, x=%%a*5+5+(%%a-1)/4*2"
	echo=!id!;!x!;0;4;2
)

echo=13;68;5;5;6
echo=8;65;2;8;3
echo=9;0;5;6;3
echo=20;0;8;7;3
echo=16;0;11;9;3
echo=17;0;14;6;3
echo=91;7;14;5;3
echo=18;13;14;5;3
echo=92;54;14;5;3
echo=93;60;14;5;3

echo=44;75;0;4;2
echo=145;80;0;4;2
echo=45;75;2;4;3
echo=46;75;5;4;3
echo=35;80;5;4;3
echo=36;80;2;4;3
echo=33;85;2;4;3
echo=34;85;5;4;3

echo=38;80;11;4;3
echo=37;75;14;4;3
echo=40;80;14;4;3
echo=39;85;14;4;3
exit /b
:setupDpKeys
echo=16;60;11;13;3
echo=17;66;14;7;3
echo=18;48;14;5;3
echo=13;106;11;4;6
exit /b
:timer
for /l %%# in () do (
	echo hi
	cmdwiz.exe getmouse 50
)