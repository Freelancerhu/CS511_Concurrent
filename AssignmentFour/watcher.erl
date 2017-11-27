-module(watcher).
-compile(export_all).
-author("Shengjie_Hu").
%%process_flag(trap_exit, true),

setup_watcher() ->
	{ok, [Input]} = io:fread("Input a number: ", "~d"),
	io : format("Your number is ~w~n", [Input]),
	createWatcher(Input, [], 0).


createWatcher(Num, SensorList, SensorId) ->
	if
		length(SensorList) == 10 ->
			io : format("start : ~n"),
			[io : format("SensorId: ~w, SensorPid: ~w~n", [SId, SPid]) || {SId, SPid} <- SensorList],
			if Num /= 0 ->
				io:format("####"),
				spawn(watcher, createWatcher, [Num, [], SensorId])
			end,
			startWatch(SensorList);
		Num == 0 ->
			io : format("start : ~n"),
			[io : format("SensorId: ~w, SensorPid: ~w~n", [SId, SPid]) || {SId, SPid} <- SensorList],
			startWatch(SensorList);
		true ->
			{SensorPid, _} = spawn_monitor(sensor, start, [self(), SensorId]),
			createWatcher(Num - 1, lists:append(SensorList, [{SensorId, SensorPid}]), SensorId + 1)
	end.

restartSensor(SensorList, SensorId) ->
	{SensorPid, _} = spawn_monitor(sensor, start, [self(), SensorId]),
	io: format("restart id: ~w, Pid: ~w~n", [SensorId, SensorPid]),
	[io : format("SensorId: ~w, SensorPid: ~w~n", [SId, SPid]) || {SId, SPid} <- lists:append(SensorList, [{SensorId, SensorPid}])],
	startWatch(lists:append(SensorList, [{SensorId, SensorPid}])).


startWatch(SensorList) ->
	receive
		{crash, SensorPid, SensorId, anomalous_reading} ->
			io : format("crash : id: ~w, Pid: ~w~n", [SensorId,SensorPid]),
			NewLists = lists:delete({SensorId, SensorPid}, SensorList),
			[io : format("SensorId: ~w, SensorPid: ~w~n", [SId, SPid]) || {SId, SPid} <- NewLists],
			restartSensor(NewLists, SensorId);
		{From, SensorId, Ref, Measurement} ->
			From ! {ok, SensorId, Ref},
			io : format("ok id: ~w, Measurement: ~w~n", [SensorId, Measurement]),
			startWatch(SensorList)
	end.



