@echo off
rem ------------------------------
rem @Author thomson
rem windows系统导入.sql文件脚本
rem @Date 2021-10-30
rem ------------------------------

rem mysql命令行参数解析：
rem -s source                引入sql文件
rem -N, --skip-column-names  不显示列信息
rem -f                       发现错误继续执行下面的命令
rem --show-warnings          显示警告以上级别的错误信息
rem 运行 goto :eof 			 CMD 返回原来调用位置并将等待下一命令。

title sql导入脚本
echo.

set PROJECT_ERL_PATH="I:/erl"
set ERL_PATH="E:/Erlang/erl8.3/bin/"
set DB_PATH="I:/database/"


:fun_main
    set inp=
    echo --------------------------------------------------------------------------
    echo source^|s             导入sql文件            ^|
    echo clear^|cls            清屏                   ^|    quit^|q          退出
	echo source_today^|td      导入今天的所有sql文件  ^|
    echo --------------------------------------------------------------------------
    set /p inp="请输入命令:"
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
	set /p sqlpath="请输入sql文件目录:"
	set /p pass="请输入密码:"
	set sqlstr="%sqlpath:~-4%"
	if %sqlstr%==".sql" (
			call :fun_source %sqlpath%	%pass%
		) else (call :fun_error 您输入的sql文件错误，请重新输入)
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
	rem search_db:list_all_db 为基于erlang的脚本
    %ERL_PATH%erl -noinput -pa ./ebin -eval "search_db:list_all_db()" -s c q
	setlocal
	set /p pass="请输入密码:"
	for /f "delims=" %%i in (today_db.txt) do (call :fun_source %DB_PATH%%%i %pass%)
	endlocal
	goto :EOF

:fun_error
	echo.
    echo ------------------------------------
    if "%1"=="" (
        echo 出错了!
    ) ELSE (
        echo %1
    )
    echo -----------------------------------
    echo.
    pause
    goto :EOF
	
rem 计算两个时间差值
rem 调用示例:
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
    set "ok=%s% 小时 %f% 分钟 %m% 秒 %n% 毫秒"
    endlocal & set "%~3=%ok%" & goto :eof
	
rem 获取本地时间
:get_localtime
    setlocal
    set lt=%date:~0,4%-%date:~5,2%-%date:~8,2% %time:~0,2%:%time:~3,2%:%time:~6,2%
    endlocal & set "%~1=%lt%" & goto :eof	
	
