@echo off
:: https://github.com/Six39
:: Batch para respaldar carpetas y directorios de una ruta a otra en Windows y al mismo tiempo depurar el origen, indica cuantos días quieres respaldar del destino para su borrado si así lo deseas
:: Puedes usarlo con tarea programada para windows y automatizar respaldos de información generada
:: Por defecto se consideran carpetas con estructura "YYYYMMDD" pero puedes configurarlo como gustes, ejemplo: c:\directorioA\YYYYMMDD   ---> d:\directorioB\YYYYMMDD


setlocal

:: unidad origen y unidad destino, Ej. uorigen=C:    udesptino=Z:

set uorigen=
set udestino=

:: dias a conservar en la unidad Respaldo: en este caso consevará los 3 últimos direcotorios y borrará desde el cuarto (4), revisará la fecha de creación del directorio y así será evaluado (no por el nombre)

set input2=-4

:: directorio A (origen) y directorio B (destino) Ej. dirA=prueba  dirB=respaldos

set dirA=
set dirB=


Call :GetDateTime Year Month Day
echo -----------------------------------------------------------------------
echo Fecha Actual: %Year%%Month%%Day%
Call :AddSubtractDate %Year% %Month% %Day% -1 Ret
echo Fecha a respaldar: %Ret%

:: aqui hago un segundo llamado para mostrar los dias a restar
Call :AddSubtractDate %Year% %Month% %Day% -4 Ret2 

set hora=%time:~0,2%:%time:~3,2%:%time:~6,2%
echo Hora de ejecucion: %hora%


:: Acciones que realizará:

echo -----------------------------------------------------------------------
echo Comienza la ejecucion del depurador, por FAVOR no cierre esta ventana  
echo esta cerrará en automatico cuando haya terminado.	
echo respaldo desde la carpeta: %uorigen%\%dirA%\%ret%\
echo a la carpeta: %udestino%\%dirB%\%ret%		
echo se borrara la carpeta (en caso de existir): %udestino%\%dirB%\%ret2%
echo -----------------------------------------------------------------------


:: genero la carpeta de logs desde el servidor primario (quien tiene los archivos al inicio)

mkdir %uorigen%\logs\>NUL

:: mando las fechas al log

echo Fecha Actual: %Year%%Month%%Day% >> %uorigen%\logs\depuradorlog_%ret%_%Year%%Month%%Day%.txt
echo Fecha a respaldar: %Ret% >> %uorigen%\logs\depuradorlog_%ret%_%Year%%Month%%Day%.txt
echo Hora de ejecucion: %hora%  >> %uorigen%\logs\depuradorlog_%ret%_%Year%%Month%%Day%.txt

:: aqui se eliminan las carpetas mayores a 4 dias de respaldos de sus propiedades de archivo
:: puede mandar un error indicando que no encuentra archivos con el criterio de búsqueda, aparece si tienes menos días existentes que los días a depurar

forfiles /p "%udestino%\%dirB%" /s /m *.* /c "cmd /c Del @path" /d %input2% 

:: aqui le pedire crear el folder con la fecha anterior en la unidad deseada
:: el >nul, indica que si existe el directorio no lo vuelva a crear

mkdir %udestino%\%dirB%\%Ret%>NUL


:: aqui le pedire mover el contenido del directorio
:: con el /MOVE indico que los mueva, con el /E indico que tambien los subdirectorios
:: mando al prompt y al log

robocopy %uorigen%\%dirA%\%Ret% %udestino%\%dirB%\%Ret% /E /MOVE >> %uorigen%\logs\depuradorlog_%ret%_%Year%%Month%%Day%.txt
timeout /t 10 /nobreak 

exit /b
:: con ese exit solo salgo de la subrutina y no de todo el codigo


:::::: Desde aquí código del usuario: Matt Williamson // Stackoverflow -- para el calculo de los días con fecha

:AddSubtractDate Year Month Day <+/-Days> Ret
::Adapted from DosTips Functions::
setlocal & set a=%4
set "yy=%~1"&set "mm=%~2"&set "dd=%~3"
set /a "yy=10000%yy% %%10000,mm=100%mm% %% 100,dd=100%dd% %% 100"
if %yy% LSS 100 set /a yy+=2000 &rem Adds 2000 to two digit years
set /a JD=dd-32075+1461*(yy+4800+(mm-14)/12)/4+367*(mm-2-(mm-14)/12*12)/12-3*((yy+4900+(mm-14)/12)/100)/4
if %a:~0,1% equ + (set /a JD=%JD%+%a:~1%) else set /a JD=%JD%-%a:~1%
set /a L= %JD%+68569,     N= 4*L/146097, L= L-(146097*N+3)/4, I= 4000*(L+1)/1461001
set /a L= L-1461*I/4+31, J= 80*L/2447,  K= L-2447*J/80,      L= J/11
set /a J= J+2-12*L,      I= 100*(N-49)+I+L
set /a YYYY= I, MM=100+J, DD=100+K
set MM=%MM:~-2% & set DD=%DD:~-2%
set ret=%YYYY: =%%MM: =%%DD: =%
endlocal & set %~5=%ret%

exit /b

:GetDateTime Year Month Day Hour Minute Second
@echo off & setlocal
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
( ENDLOCAL
     IF "%~1" NEQ "" set "%~1=%YYYY%" 
     IF "%~2" NEQ "" set "%~2=%MM%" 
     IF "%~3" NEQ "" set "%~3=%DD%"
     IF "%~4" NEQ "" set "%~4=%HH%" 
     IF "%~5" NEQ "" set "%~5=%Min%"
     IF "%~6" NEQ "" set "%~6=%Sec%"
)

exit /b

