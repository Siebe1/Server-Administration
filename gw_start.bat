@ECHO off

IF NOT ""%1"" == """" GOTO START

SETLOCAL

SET /P _sure=Do you want to start Siebel GW (y/n)?

IF /I "%_sure%" NEQ "Y" GOTO NO_SURE

:START

ECHO _____________________
ECHO Here could be your logo
ECHO _____________________

:: Entering timeouts

SET "_gwtcgw_timeout=60"


SET "_cd=%cd%"
IF NOT EXIST "%_cd%\LOG\" MKDIR %_cd%\LOG || GOTO ERROR
SET _mydate=%date:~4,2%_%date:~7,2%_%date:~10%
SET _mytime=%time:~0,2%_%time:~3,2%_%time:~6,2%_%time:~9%
SET _logfile="%_cd%\LOG\GW_start_LOG_%_mydate%_%_mytime%.TXT"


FOR /F "tokens=* USEBACKQ" %%F IN ('whoami') DO (
SET _user=%%F
)

FOR /F "tokens=* USEBACKQ" %%F IN ('hostname') DO (
SET _mashine=%%F
)

TIME /T >> %_logfile% && ECHO OS USER IS %_user% >> %_logfile% && ECHO PCName is %_mashine% >> %_logfile% || GOTO ERROR

ECHO ################## >> %_logfile% && TIME /T >> %_logfile% && ECHO RUN GW! >> %_logfile%


ECHO STARTING GWTCs
::GWTC
FOR /F "delims== tokens=1,2" %%a IN (%_cd%\gwtc.conf) DO (

ECHO %%a
sc \\%%a start %%b

IF "%ERRORLEVEL%"=="0" (
			TIME /T >> %_logfile% && ECHO GW TC STARTED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			) ELSE (
			ECHO @@@@ERROR@@@@ >> %_logfile% && TIME /T >> %_logfile% && ECHO GW TC NOT STARTED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			)
			TIMEOUT 5				
)

TIMEOUT %_gwtcgw_timeout% /NOBREAK

::GW
FOR /F "delims== tokens=1,2" %%a IN (%_cd%\gwtc.conf) DO (

ECHO %%a
sc \\%%a start gtwyns

IF "%ERRORLEVEL%"=="0" (
			TIME /T >> %_logfile% && ECHO GW STARTED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			) ELSE (
			ECHO @@@@ERROR@@@@ >> %_logfile% && TIME /T >> %_logfile% && ECHO GW NOT STARTED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			)
			TIMEOUT 5				
)


ECHO GW STARTED

ECHO ################## >> %_logfile% && TIME /T >> %_logfile% && ECHO GW STARTED >> %_logfile%

GOTO FINISH

:ERROR

ECHO ERROR!

:NO_SURE
GOTO FINISH

:FINISH
ENDLOCAL
IF NOT ""%1"" == """" PAUSE