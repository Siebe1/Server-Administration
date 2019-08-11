@ECHO off

IF NOT ""%1"" == """" GOTO START

SETLOCAL

SET /P _sure=Do you want to stop Siebel GW (y/n)?

IF /I "%_sure%" NEQ "Y" GOTO NO_SURE

:START

ECHO _____________________
ECHO Here could be your logo
ECHO _____________________

SET "_cd=%cd%"
IF NOT EXIST "%_cd%\LOG\" MKDIR %_cd%\LOG || GOTO ERROR
SET _mydate=%date:~4,2%_%date:~7,2%_%date:~10%
SET _mytime=%time:~0,2%_%time:~3,2%_%time:~6,2%_%time:~9%
SET _logfile="%_cd%\LOG\GW_stop_LOG_%_mydate%_%_mytime%.TXT"


FOR /F "tokens=* USEBACKQ" %%F IN ('whoami') DO (
SET _user=%%F
)

FOR /F "tokens=* USEBACKQ" %%F IN ('hostname') DO (
SET _mashine=%%F
)

TIME /T >> %_logfile% && ECHO OS USER IS %_user% >> %_logfile% && ECHO PCName is %_mashine% >> %_logfile% || GOTO ERROR

ECHO ################## >> %_logfile% && TIME /T >> %_logfile% && ECHO STOP GW! >> %_logfile%


ECHO STARTING GWTCs
::GWTC
FOR /F "delims== tokens=1,2" %%a IN (%_cd%\gwtc.conf) DO (

ECHO %%a
sc \\%%a stop %%b

IF "%ERRORLEVEL%"=="0" (
			TIME /T >> %_logfile% && ECHO GW TC STOPPED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			) ELSE (
			ECHO @@@@ERROR@@@@ >> %_logfile% && TIME /T >> %_logfile% && ECHO GW TC NOT STOPPED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			)
			TIMEOUT 5				
)


::GW
FOR /F "delims== tokens=1,2" %%a IN (%_cd%\gwtc.conf) DO (

ECHO %%a
sc \\%%a stop gtwyns

IF "%ERRORLEVEL%"=="0" (
			TIME /T >> %_logfile% && ECHO GW STOPPED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			) ELSE (
			ECHO @@@@ERROR@@@@ >> %_logfile% && TIME /T >> %_logfile% && ECHO GW NOT STOPPED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			)
			TIMEOUT 5				
)


ECHO GW STOPPED

ECHO ################## >> %_logfile% && TIME /T >> %_logfile% && ECHO GW STOPPED >> %_logfile%

GOTO FINISH

:ERROR

ECHO ERROR!

:NO_SURE
GOTO FINISH

:FINISH
ENDLOCAL
IF NOT ""%1"" == """" PAUSE