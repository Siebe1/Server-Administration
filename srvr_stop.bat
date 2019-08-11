@ECHO off

IF NOT ""%1"" == """" GOTO START

SETLOCAL

SET /P _sure=Do you want to stop Siebel Environment (y/n)?

IF /I "%_sure%" NEQ "Y" GOTO NO_SURE

:START

ECHO _____________________
ECHO Here could be your logo
ECHO _____________________


:: Entering timeouts

SET "_check_timeout=100"
SET "_stop_timeout=600"

SET "_alive_proc_fl=N"
SET "_alive_service_fl=N"
SET "_iterations=10"

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

ECHO ################## >> %_logfile% && TIME /T >> %_logfile% && ECHO STOPPING Environment! >> %_logfile%

::ES
ECHO STOPPING ES 

FOR /F "delims== tokens=1,2" %%a IN (%_cd%\es.conf) DO (

ECHO %%a
sc \\%%a stop %%b

IF "%ERRORLEVEL%"=="0" (
			TIME /T >> %_logfile% && ECHO ES STOPPED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			) ELSE (
			ECHO @@@@ERROR@@@@ >> %_logfile% && TIME /T >> %_logfile% && ECHO ES NOT STOPPED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			)
			TIMEOUT 5				
)

ECHO ES STOPPED

ECHO STOPPING TCS
::ESTC
FOR /F "delims== tokens=1,2" %%a IN (%_cd%\estc.conf) DO (

ECHO %%a
sc \\%%a stop %%b

IF "%ERRORLEVEL%"=="0" (
			TIME /T >> %_logfile% && ECHO ES TC STOPPED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			) ELSE (
			ECHO @@@@ERROR@@@@ >> %_logfile% && TIME /T >> %_logfile% && ECHO ES TC NOT STOPPED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			)
			TIMEOUT 5				
)

::AITC
FOR /F "delims== tokens=1,2" %%a IN (%_cd%\aitc.conf) DO (

ECHO %%a
sc \\%%a stop %%b

IF "%ERRORLEVEL%"=="0" (
			TIME /T >> %_logfile% && ECHO AI TC STOPPED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			) ELSE (
			ECHO @@@@ERROR@@@@ >> %_logfile% && TIME /T >> %_logfile% && ECHO AI TC NOT STOPPED %_user% >> %_logfile% && ECHO %%a >> %_logfile%
			)
			TIMEOUT 5				
)

ECHO TCS STOPPED


ECHO STOPPING GW CLUSTER
TIME /T >> %_logfile% && ECHO GW CLUSTER STOPPING %_user% >> %_logfile%

CALL %_cd%\gw_stop.bat Script

ECHO GW CLUSTER STOPPED

:: CHECKS

:CHECK

::FOR ALIVE SERVICES
ECHO CHECK STARTED

SET "_alive_service_fl=N"

TIMEOUT %_check_timeout% /NOBREAK

FOR /F "delims== tokens=1,2" %%a IN (%_cd%\estc.conf) DO (

sc \\%%a query %%b | findstr /i "STOPPED" || SET "_alive_service_fl=Y" && ECHO SERVICE %%b ON %%a IS STILL WORKING. WE HAVE TO WAIT MORE TIME.
)

IF "%_iterations%"=="0" ( GOTO CHECK_FAIL)
SET /A _iterations-= 1
IF "%_alive_service_fl%"=="Y" ( GOTO CHECK)

:: FOR ALIVE PROCESSES

SET "_alive_proc_fl=N"

FOR /F "delims== tokens=1,2" %%a IN (%_cd%\estc.conf) DO (

tasklist /s %%a /fi "imagename eq sieb*" | find /i "No tasks are running" >nul && SET "_alive_proc_fl=Y" || (ECHO  Still alive processes on %%a >> %_logfile% && tasklist /s %%a /fi "imagename eq sieb*" >> %_logfile%))

IF "%_alive_proc_fl%"=="Y" ( GOTO CHECK_PASSED)

:: Taskkill

FOR /F "delims== tokens=1,2" %%a IN (%_cd%\estc.conf) DO (
	FOR /F "tokens=2 delims= " %%b IN (tasklist /s \\%%a /nh /fi "imagename eq sieb*") DO ( taskkill /F /s \\%%a /PID %%b
	ECHO.
	ECHO /////////
	ECHO TASKKILL
	ECHO %%a
	ECHO %%b
	
	)
ECHO ALIVE PROCESSES ARE KILLED

GOTO DONE

:CHECK_PASSED

ECHO CHECK PASSED

GOTO DONE


:CHECK_FAIL

ECHO NOT ALL SIEBEL SERVICES STOPPED

FOR /F "delims== tokens=1,2" %%a IN (%_cd%\estc.conf) DO (
sc \\%%a query %%b | findstr /i "STOPPED">nul || ECHO \\\\\\\\\\\\\\
sc \\%%a query %%b | findstr /i "STOPPED">nul || ECHO %%a
sc \\%%a query %%b | findstr /i "STOPPED">nul || ECHO sc \\%%a query %%b | findstr /i "SERVICE_NAME STATE"

ECHO \\\\\\\\\\\\\\ >> %_logfile% && TIME /T >> %_logfile% && ECHO %%a >> %_logfile% && ECHO sc \\%%a query %%b >> %_logfile%
)

:ERROR

ECHO ERROR!
GOTO FINISH

:NO_SURE
GOTO FINISH

:DONE
TIMEOUT %_stop_timeout% /NOBREAK
ECHO ################## >> %_logfile% && TIME /T >> %_logfile% && ECHO SERVER STOPPED >> %_logfile%
ECHO SERVER STOPPED
GOTO FINISH

:FINISH
ENDLOCAL
IF NOT ""%1"" == """" PAUSE