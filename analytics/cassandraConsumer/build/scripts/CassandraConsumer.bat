@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  CassandraConsumer startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

@rem Add default JVM options here. You can also use JAVA_OPTS and CASSANDRA_CONSUMER_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%..

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto init

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto init

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:init
@rem Get command-line arguments, handling Windowz variants

if not "%OS%" == "Windows_NT" goto win9xME_args
if "%@eval[2+2]" == "4" goto 4NT_args

:win9xME_args
@rem Slurp the command line arguments.
set CMD_LINE_ARGS=
set _SKIP=2

:win9xME_args_slurp
if "x%~1" == "x" goto execute

set CMD_LINE_ARGS=%*
goto execute

:4NT_args
@rem Get arguments from the 4NT Shell from JP Software
set CMD_LINE_ARGS=%$

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\lib\CassandraConsumer-1.0-SNAPSHOT.jar;%APP_HOME%\lib\kafka_2.8.2-0.8.1.jar;%APP_HOME%\lib\log4j-1.2.16.jar;%APP_HOME%\lib\guava-18.0.jar;%APP_HOME%\lib\jettison-1.3.7.jar;%APP_HOME%\lib\cassandra-driver-core-2.2.0-rc3.jar;%APP_HOME%\lib\json-simple-1.1.1.jar;%APP_HOME%\lib\slf4j-simple-1.7.13.jar;%APP_HOME%\lib\scala-library-2.8.2.jar;%APP_HOME%\lib\metrics-annotation-2.2.0.jar;%APP_HOME%\lib\metrics-core-2.2.0.jar;%APP_HOME%\lib\snappy-java-1.0.5.jar;%APP_HOME%\lib\zookeeper-3.3.4.jar;%APP_HOME%\lib\jopt-simple-3.2.jar;%APP_HOME%\lib\zkclient-0.3.jar;%APP_HOME%\lib\stax-api-1.0.1.jar;%APP_HOME%\lib\netty-handler-4.0.27.Final.jar;%APP_HOME%\lib\metrics-core-3.0.2.jar;%APP_HOME%\lib\junit-4.10.jar;%APP_HOME%\lib\slf4j-api-1.7.13.jar;%APP_HOME%\lib\jline-0.9.94.jar;%APP_HOME%\lib\netty-buffer-4.0.27.Final.jar;%APP_HOME%\lib\netty-transport-4.0.27.Final.jar;%APP_HOME%\lib\netty-codec-4.0.27.Final.jar;%APP_HOME%\lib\hamcrest-core-1.1.jar;%APP_HOME%\lib\netty-common-4.0.27.Final.jar

@rem Execute CassandraConsumer
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %CASSANDRA_CONSUMER_OPTS%  -classpath "%CLASSPATH%" CassandraConsumer %CMD_LINE_ARGS%

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable CASSANDRA_CONSUMER_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%CASSANDRA_CONSUMER_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
