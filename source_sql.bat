@echo off
rem ------------------------------
rem @Author thomson
rem windowsϵͳ����.sql�ļ��ű�
rem @Date 2021-10-30
rem ------------------------------

rem mysql�����в���������
rem -s source                ����sql�ļ�
rem -N, --skip-column-names  ����ʾ����Ϣ
rem -f                       ���ִ������ִ�����������
rem --show-warnings          ��ʾ�������ϼ���Ĵ�����Ϣ
rem ���� goto :eof 			 CMD ����ԭ������λ�ò����ȴ���һ���

title sql����ű�
echo.

set PROJECT_ERL_PATH="I:/erl"
set ERL_PATH="E:/Erlang/erl8.3/bin/"
set DB_PATH="I:/database/"


:fun_main
    set inp=
    echo --------------------------------------------------------------------------
    echo source^|s             ����sql�ļ�            ^|
    echo clear^|cls            ����                   ^|    quit^|q          �˳�
	echo source_today^|td      ������������sql�ļ�  ^|
    echo --------------------------------------------------------------------------
    set /p inp="����������:"
    goto fun_routing

:fun_routing
    if "%inp%"=="source" call :fun_source
    if "%inp%"=="s" call :fun_sql_path
    if "%inp%"=="source_today" call :fun_sql_source_today
    if "%inp%"=="td" call :fun_sql_source_today
    if "%inp%"=="cls" cls
    if "%inp%"=="clear" cls
    if "%inp%"=="quit" goto :EOF
    if "%inp%"=="q" goto :EOF
    echo.
    goto fun_main
 
:fun_sql_path
	echo.
	setlocal
	set /p sqlpath="������sql�ļ�Ŀ¼:"
	set /p pass="����������:"
	set sqlstr="%sqlpath:~-4%"
	if %sqlstr%==".sql" (
			call :fun_source %sqlpath%	%pass%
		) else (call :fun_error �������sql�ļ���������������)
	endlocal	
	goto :EOF

:fun_source 
	rem mysql -hlocalhost -uroot -Ddb_name -p -s -N -f --show-warnings < %1
	rem "C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql" -uroot -p %2 -f -Ddb_name<%1
	call :get_localtime StartTimeStr
	"C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql" -uroot -p%2 -f -Ddb_name <%1 2>%StartTimeStr%_db_log.txt
	goto :EOF
	
	
:fun_sql_source_today
    cd %PROJECT_ERL_PATH%
	rem search_db:list_all_db Ϊ����erlang�Ľű�
    %ERL_PATH%erl -noinput -pa ./ebin -eval "search_db:list_all_db()" -s c q
	setlocal
	set /p pass="����������:"
	for /f "delims=" %%i in (today_db.txt) do (call :fun_source %DB_PATH%%%i %pass%)
	endlocal
	goto :EOF

:fun_error
	echo.
    echo ------------------------------------
    if "%1"=="" (
        echo ������!
    ) ELSE (
        echo %1
    )
    echo -----------------------------------
    echo.
    pause
    goto :EOF
	
rem ��������ʱ���ֵ
rem ����ʾ��:
rem set StartTime=%time%
rem echo do something
rem call :calc_time_diff "%StartTime%" "%time%" "RunTime"
rem echo cost time %RunTime%
:calc_time_diff
    setlocal
    set /a n=0
    for /f "tokens=1-8 delims=.: " %%a in ("%~1:%~2") do (
            set /a n-=1%%a*3600000+1%%b*60000+1%%c*1000+1%%d*10
            set /a n+=1%%e*3600000+1%%f*60000+1%%g*1000+1%%h*10
    )
    set /a s=n/3600000,n=n%%3600000,f=n/60000,n=n%%60000,m=n/1000,n=n%%1000
    set "ok=%s% Сʱ %f% ���� %m% �� %n% ����"
    endlocal & set "%~3=%ok%" & goto :eof
	
rem ��ȡ����ʱ��
:get_localtime
    setlocal
    set lt=%date:~0,4%-%date:~5,2%-%date:~8,2% %time:~0,2%:%time:~3,2%:%time:~6,2%
    endlocal & set "%~1=%lt%" & goto :eof	
	
