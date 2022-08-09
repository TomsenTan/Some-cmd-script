%%%-------------------------------------------------------------------
%%% @author Thomson
%%% @doc
%%%     查找今天内更新的db并写入db_log.txt文件
%%% @end
%%% Created : 2022-06-16
%%%-------------------------------------------------------------------
-module(search_db).

-include("common.hrl").
-include_lib("kernel/include/file.hrl").
-compile(export_all).

%% API
-export([
    execute_db/0
    ,list_all_db/0
]).
-define(FORMAT_CHAR(Format, Args), unicode:characters_to_binary(io_lib:format(Format, Args))).

execute_db() ->
    %% TODO: 初始化db
    SqlFiles = list_all_db(),
    execute(SqlFiles).

list_all_db() ->
    {NowDate, _} = calendar:local_time(),
    SqlFileList = dir_file_list("../sql"),
    FilterSqlFiles = filter_file(SqlFileList, NowDate, []),
    {ok, IoDevice} = file:open("today_db.txt", [write, {encoding, utf8}]),
    F = fun(FilName) ->
        % io:format(IoDevice, "~p~n", FilName)
        % io:write(IoDevice, FilName)
        file:write(IoDevice, ?FORMAT_CHAR("~ts~n", [FilName]))
    end,
    lists:map(F, FilterSqlFiles),
    file:close(IoDevice),
    FilterSqlFiles.

execute([]) -> db_upgrade;
execute([FileName|L]) ->
    db_upgrade:execute_sql("../sql/"++FileName++".sql"),
    execute(L).

%% 文件夹目录下的文件
dir_file_list("") -> [];
dir_file_list(DirName) ->
    %% 带有扩展名的文件名列表 也带双引号{ok, ["a.sql", "b.sql"]}
    {ok, List} = file:list_dir(DirName),
    %% 没有扩展名的文件名列表 但是带有双引号 ["a", "b"]
    FileList = [
        case filelib:is_dir(OneFile) of
            true -> dir_file_list(OneFile);
            _ -> OneFile
        end || OneFile <- List
        ,filename:extension(OneFile) =:= ".sql"
    ],
    FileList.

filter_file([], _NowDate, FilterFileList) -> FilterFileList;
filter_file([FileName|L], NowDate, FilterFileList) ->
    NewFilterFileList =
    case file:read_file_info("../sql/"++FileName) of
        {ok, #file_info{mtime = {NowDate, _Time}}} ->
            case filename:rootname(FileName) =/= "aaa" of
                true ->
                    [FileName|FilterFileList];
                _ ->
                    FilterFileList
            end;
        _ ->
            FilterFileList
    end,
    filter_file(L, NowDate, NewFilterFileList).
