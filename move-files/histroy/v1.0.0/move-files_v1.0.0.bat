@echo off
rem *********************************
rem **move files
rem **ver:1.0.0
rem *********************************
:main
set _g_info_str=[%date% %time%][INFO]:&set _g_error_str=[%date% %time%][ERROR]:
set _g_current_dir=%cd%
set _g_log_dir=%_g_current_dir%\log
set _g_log_file_dir=%_g_log_dir%\log.txt
setlocal
set "_src_dir="
set "_target_dir="
:check_dir
echo %_g_info_str%check dir...
if not exist %_src_dir% (
echo %_g_error_str%src dir error
goto end
)
if not exist %_target_dir% (
echo %_g_error_str%target dir error
goto end
)
if not exist %_g_log_dir% (
md %_g_log_dir%
)
goto copy_files
:copy_files
echo %_g_info_str%create new dir or copy files...
set _current_date=%date:~0,10%
set _current_time=%time:~0,8%
set _current_date_time=%_current_date%%_current_time%
setlocal enabledelayedexpansion
for /r %_src_dir% %%i in (.,*) do (
set _target_create_date_time=%%~ti
set _target_create_date=!_target_create_date_time:~0,10!
set _target_create_time=!_target_create_date_time:~12!
set _target_create_date_time1=!_target_create_date!!_target_create_time!
call :calc_days _calc_days_return !_target_create_date_time1! %_current_date_time%
if !_calc_days_return! GEQ 20 (
set "_dir_file=%%i"
if !_dir_file:~-2! == \. (
set _copy_dir=!_dir_file:~0,-2!
call :find_end_index _find_end_index_return "!_copy_dir!" "%_src_dir%"
call :compose_dir_str _compose_dir_str_return "%_target_dir%" "!_copy_dir!" !_find_end_index_return!
if not exist !_compose_dir_str_return! (
md "!_compose_dir_str_return!"
echo %_g_info_str%create new dir:!_compose_dir_str_return!
echo %_g_info_str%create new dir:!_compose_dir_str_return!>>%_g_log_file_dir%
)
) else (
call :find_end_index _find_end_index_return1 "!_dir_file!" "%_src_dir%"
call :find_char_index_right_to_left _find_char_index_right_to_left_return "!_dir_file!"
call :compose_dir_str _compose_dir_str_return1 "%_target_dir%" "!_dir_file!" !_find_end_index_return1! !_find_char_index_right_to_left_return!
copy "!_dir_file!" "!_compose_dir_str_return1!" /y|find "ря">nul&&(
echo %_g_info_str%copy file:!_dir_file!==^>!_compose_dir_str_return1!
echo %_g_info_str%copy file:!_dir_file!==^>!_compose_dir_str_return1!>>%_g_log_file_dir%
)
)
)
)
endlocal
goto end
rem function calc_days
rem p1 return p2 dt1 p3 dt2
:calc_days
setlocal&set "dt1=%2"&set "dt2=%3"&set "y1=!dt1:~0,4!"&set "m1=!dt1:~5,2!"&set "d1=!dt1:~8,2!"&set "y2=!dt2:~0,4!"&set "m2=!dt2:~5,2!"&set "d2=!dt2:~8,2!"
if %dt1:~11,1% == : (
set "h1=%dt1:~10,1%"&set "f1=%dt1:~12,2%"
) else (
set "h1=%dt1:~10,2%"&set "f1=%dt1:~13,2%"
)
if %dt2:~11,1% == : (
set h2=%dt2:~10,1%
set f2=%dt2:~12,2%
) else (
set h2=%dt2:~10,2%
set f2=%dt2:~13,2%
)
set /a out=d2-d1+30*(m2-m1)+m2/9*-~m2/2+!(m2/9)*m2/2+!!(m2/3)*((y2%%4)-(y2%%100)+(y2%%400)-2)-m1/9*+~m1/2-!(m1/9)*m1/2-!!(m1/3)*((y1%%4)-(y1%%100)+(y1%%400)-2)+(y2-y1)*365+~-y2/4-~-y2/100+~-y2/400-~-y1/4+~-y1/100-~-y1/400+((h2-h1)*3600+(f2-f1)*60)/86400
endlocal&set "%1=%out%"&goto:eof
rem function find_char_index_right_to_left
rem p1 return p2 srcstr
:find_char_index_right_to_left
setlocal&set _src_str=%2&set _index=0
set "_src_str=%_src_str:~1,-1%"
:find_char_index_right_to_left-next
if "%_src_str:~-1%" == "\" (
goto find_char_index_right_to_left-find_index
) else (
set /a _index+=1
set "_src_str=%_src_str:~0,-1%"
goto find_char_index_right_to_left-next
)
:find_char_index_right_to_left-find_index
endlocal&set "%1=%_index%"&goto:eof
rem function compose_dir_str
rem p1 return p2 srcstr p3 cutedstr p4 index1 p5 index2
:compose_dir_str
setlocal&set "_src_str=%2"&set "_cuted_str=%3"&set _index1=%4&set _index2=%5
set "_src_str=%_src_str:~1,-1%"
set "_cuted_str=%_cuted_str:~1,-1%"
if not defined _index2 (
set "_cuted_str=!_cuted_str:~%_index1%!"
) else (
set "_cuted_str=!_cuted_str:~%_index1%,-%_index2%!"
)
endlocal&set "%1=%_src_str%%_cuted_str%"&goto:eof
rem function find_end_index
rem p1 index p2 src_str p3 parrent_str
:find_end_index
setlocal&set _src_str=%2&set _parrent_str=%3&set _str_index=0
set _src_str=%_src_str:~1,-1%
set _parrent_str=%_parrent_str:~1,-1%
:find_end_index-next
if not defined _parrent_str (
goto find_end_index-find_index
)
if %_src_str:~0,1% == %_parrent_str:~0,1% (
set /a _str_index+=1
) else (
goto find_end_index-find_index
)
set _src_str=%_src_str:~1%
set _parrent_str=%_parrent_str:~1%
goto find_end_index-next
:find_end_index-find_index
endlocal&set "%1=%_str_index%"&goto:eof
:end
pause