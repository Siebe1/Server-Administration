@ECHO off

IF NOT ""%1"" == """" GOTO START

SETLOCAL

SET /P _sure=Do you want to start Siebel Environment (Y/N)?

IF /I "%_sure%" NEQ "Y" GOTO NO_SURE

:START

ECHO _____________________
ECHO Here could be your logo
ECHO _____________________

:: Entering timeouts

SET "_gwestc_timeout=100"
SET "_estces_timeout=100"
SET "_srvr_wait_timeout=600"

SET "_cd=%cd%"
IF NOT EXIST "%_cd%\LOG\" MKDIR %_cd%\LOG || GOTO ERROR
SET _mydate=%date:~4,2%_%date:~7,2%_%date:~10%
SET _mytime=%time:~0,2%_%time:~3,2%_%time:~6,2%_%time:~9%
SET _logfile="%_cd%\LOG\SRVR_start_LOG_%_mydate%_%_mytime%.TXT"



FOR /F "tokens=* USEBACKQ" %%F IN ('whoami') DO (
SET _user=%%F
)

FOR /F "tokens=* USEBACKQ" %%F IN ('hostname') DO (
SET _mashine=%%F
)

TIME /T >> %_logfile% && ECHO OS USER IS %_user% >> %_logfile% && ECHO PCName is %_mashine% >> %_logfile% || GOTO ERROR

ECHO ################## >> %_logfile% && TIME /T >> %_logfile% && ECHO RUN! >> %_logfile%


ECHO STARTING GW CLUSTER
TIME /T >> %_logfile% && ECHO GW CLUSTER STARTING %_user% >> %_logfile%

CALL %_cd%\gw_start.bat Script
TIMEOUT %_gwestc_timeout% /NOBREAK

ECHO GW CLUSTER STARTED

ECHO STARTING TCS
::ESTC
FOR /F "delims== tokens=1,2" %%a IN (%_cd%\estc.conf) DO (

ECHO %%a
sc \\%%a start %%b

IF "%ERRORLEVEL%"=="0" (
			TIME /T >> %_logfile% && ECHO ES TC STARTED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			) ELSE (
			ECHO @@@@ERROR@@@@ >> %_logfile% && TIME /T >> %_logfile% && ECHO ES TC NOT STARTED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			)
			TIMEOUT 5				
)

::AITC
FOR /F "delims== tokens=1,2" %%a IN (%_cd%\aitc.conf) DO (

ECHO %%a
sc \\%%a start %%b

IF "%ERRORLEVEL%"=="0" (
			TIME /T >> %_logfile% && ECHO AI TC STARTED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			) ELSE (
			ECHO @@@@ERROR@@@@ >> %_logfile% && TIME /T >> %_logfile% && ECHO AI TC NOT STARTED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			)
			TIMEOUT 5				
)

TIMEOUT %_estces_timeout% /NOBREAK

ECHO TCS STARTED

::ES
ECHO STARTING ES 

FOR /F "delims== tokens=1,2" %%a IN (%_cd%\es.conf) DO (

ECHO %%a
sc \\%%a start %%b

IF "%ERRORLEVEL%"=="0" (
			TIME /T >> %_logfile% && ECHO ES STARTED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			) ELSE (
			ECHO @@@@ERROR@@@@ >> %_logfile% && TIME /T >> %_logfile% && ECHO ES NOT STARTED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			)
			TIMEOUT 5				
)

TIMEOUT %_srvr_wait_timeout% /NOBREAK


ECHO ES STARTED
ECHO ################## >> %_logfile% && TIME /T >> %_logfile% && ECHO SERVER STARTED >> %_logfile%

GOTO FINISH

:ERROR

ECHO ERROR!

:NO_SURE
GOTO FINISH

:FINISH
ENDLOCAL
IF NOT ""%1"" == """" PAUSE