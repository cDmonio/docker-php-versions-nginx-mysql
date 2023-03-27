@echo Off
set mypath=%cd%

@REM ECHO %mypath%

SETLOCAL EnableExtensions EnableDelayedExpansion

set "hostspath=%SystemRoot%\System32\drivers\etc\hosts"

set "domainExtensionTest=.test      #docker GITHUB /cDmonio!"

@REM recorrer el directorio actual
for /d %%d in (php*.*) do (
    set test=%%d
    @REM Excluir la carpeta php, por que la primera carpeta es de config .ini, etc
    if NOT "!test!" == "php" (
        @REM echo !test!
        pushd "%mypath%\!test!
        @REM Guardar en variables las carpetas que tenemos
        for /d /r %%a in (.\*) do (
            set "newHost=127.0.0.1      %%~nxa!domainExtensionTest!"

            set /a numhosts+=1
            set "host!numhosts!=!newHost!"

            @REM echo host!numhosts!
        )
    )
)

@REM for /l %%n in (1,1,%n%) do (
@REM     set /a numhosts+=1
@REM     set "host!numhosts!=!newHosts[%%n]!"
@REM     @REM echo !newHosts[%%n]!
@REM )

>"%hostspath%.new" (
    rem Parse the hosts file, skipping the already present hosts from our list.
    rem Blank lines are preserved using findstr trick.
    for /f "delims=: tokens=1*" %%a in ('%SystemRoot%\System32\findstr.exe /n /r /c:".*" "%hostspath%"') do (
        set skipline=
        for /L %%h in (1,1,!numhosts!) do (
            if /i "%%b"=="!host%%h!" (
                set skipline=false
                set found%%h=true
                echo Host exists:  %%b 1>&2
            )
        )
        if not "!skipline!"=="true" echo.%%b
    )
    for /L %%h in (1,1,!numhosts!) do (
        if not "!found%%h!"=="true" echo + !host%%h! 1>&2 & echo !host%%h!
    )
)
move /y "%hostspath%" "%hostspath%.bak" >nul || echo Can't backup %hostspath%
move /y "%hostspath%.new" "%hostspath%" >nul || echo Can't update %hostspath%
endlocal
pause