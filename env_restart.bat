@ECHO off

:START
SETLOCAL

ECHO _____________________
ECHO Here could be your logo
ECHO _____________________


SET /P _sure=Do you want to restart Siebel Environment (y/n)?

IF /I "%_sure%" NEQ "Y" GOTO NO_SURE

SET "_cd=%cd%"
IF NOT EXIST "%_cd%\LOG\" MKDIR %_cd%\LOG || GOTO ERROR
SET _mydate=%date:~4,2%_%date:~7,2%_%date:~10%
SET _mytime=%time:~0,2%_%time:~3,2%_%time:~6,2%_%time:~9%
SET _logfile="%_cd%\LOG\MAIN_LOG_%_mydate%_%_mytime%.TXT"


FOR /F "tokens=* USEBACKQ" %%F IN ('whoami') DO (
SET _user=%%F
)

FOR /F "tokens=* USEBACKQ" %%F IN ('hostname') DO (
SET _mashine=%%F
)

TIME /T >> %_logfile% && ECHO OS USER IS %_user% >> %_logfile% && ECHO PCName is %_mashine% >> %_logfile% || GOTO ERROR

ECHO ################## >> %_logfile% && TIME /T >> %_logfile% && ECHO RUN! >> %_logfile%

CALL %_cd%\srvr_stop.bat Script

CALL %_cd%\srvr_start.bat Script

GOTO FINISH

:ERROR

ECHO ERROR!

:FINISH
ENDLOCAL
PAUSE
EXIT

:NO_SURE
EXIT