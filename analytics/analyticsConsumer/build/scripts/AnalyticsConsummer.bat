@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  AnalyticsConsummer startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

@rem Add default JVM options here. You can also use JAVA_OPTS and ANALYTICS_CONSUMMER_OPTS to pass JVM options to this script.
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

set CLASSPATH=%APP_HOME%\lib\AnalyticsConsummer-1.0-SNAPSHOT.jar;%APP_HOME%\lib\kafka_2.8.2-0.8.1.jar;%APP_HOME%\lib\log4j-1.2.16.jar;%APP_HOME%\lib\guava-18.0.jar;%APP_HOME%\lib\jettison-1.3.7.jar;%APP_HOME%\lib\json-simple-1.1.1.jar;%APP_HOME%\lib\slf4j-simple-1.7.13.jar;%APP_HOME%\lib\storm-core-0.10.0.jar;%APP_HOME%\lib\storm-kafka-0.10.0.jar;%APP_HOME%\lib\config-1.2.1.jar;%APP_HOME%\lib\redisson-2.2.0.jar;%APP_HOME%\lib\commons-lang3-3.4.jar;%APP_HOME%\lib\zookeeper-3.4.6.jar;%APP_HOME%\lib\commons-collections-3.2.2.jar;%APP_HOME%\lib\scala-library-2.8.2.jar;%APP_HOME%\lib\metrics-annotation-2.2.0.jar;%APP_HOME%\lib\metrics-core-2.2.0.jar;%APP_HOME%\lib\snappy-java-1.0.5.jar;%APP_HOME%\lib\jopt-simple-3.2.jar;%APP_HOME%\lib\zkclient-0.3.jar;%APP_HOME%\lib\slf4j-log4j12-1.6.1.jar;%APP_HOME%\lib\stax-api-1.0.1.jar;%APP_HOME%\lib\netty-3.7.0.Final.jar;%APP_HOME%\lib\junit-4.10.jar;%APP_HOME%\lib\slf4j-api-1.7.13.jar;%APP_HOME%\lib\kryo-2.21.jar;%APP_HOME%\lib\clojure-1.6.0.jar;%APP_HOME%\lib\disruptor-2.10.4.jar;%APP_HOME%\lib\log4j-api-2.1.jar;%APP_HOME%\lib\log4j-core-2.1.jar;%APP_HOME%\lib\log4j-slf4j-impl-2.1.jar;%APP_HOME%\lib\log4j-over-slf4j-1.6.6.jar;%APP_HOME%\lib\hadoop-auth-2.4.0.jar;%APP_HOME%\lib\servlet-api-2.5.jar;%APP_HOME%\lib\commons-io-2.4.jar;%APP_HOME%\lib\curator-framework-2.5.0.jar;%APP_HOME%\lib\commons-lang-2.5.jar;%APP_HOME%\lib\netty-common-4.0.32.Final.jar;%APP_HOME%\lib\netty-codec-4.0.32.Final.jar;%APP_HOME%\lib\netty-buffer-4.0.32.Final.jar;%APP_HOME%\lib\netty-transport-4.0.32.Final.jar;%APP_HOME%\lib\netty-handler-4.0.32.Final.jar;%APP_HOME%\lib\reactor-stream-2.0.7.RELEASE.jar;%APP_HOME%\lib\jackson-core-2.6.3.jar;%APP_HOME%\lib\jackson-databind-2.6.3.jar;%APP_HOME%\lib\jackson-dataformat-cbor-2.6.3.jar;%APP_HOME%\lib\jline-0.9.94.jar;%APP_HOME%\lib\reflectasm-1.07-shaded.jar;%APP_HOME%\lib\minlog-1.2.jar;%APP_HOME%\lib\curator-client-2.5.0.jar;%APP_HOME%\lib\reactor-core-2.0.7.RELEASE.jar;%APP_HOME%\lib\jackson-annotations-2.6.0.jar;%APP_HOME%\lib\asm-4.0.jar;%APP_HOME%\lib\reactive-streams-1.0.0.jar;%APP_HOME%\lib\hamcrest-core-1.1.jar

@rem Execute AnalyticsConsummer
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %ANALYTICS_CONSUMMER_OPTS%  -classpath "%CLASSPATH%" AnalyticsConsumer %CMD_LINE_ARGS%

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable ANALYTICS_CONSUMMER_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%ANALYTICS_CONSUMMER_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
