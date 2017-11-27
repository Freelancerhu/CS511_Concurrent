-module(sensor).
-compile(export_all).
-author("Shengjie_Hu").

start(WatcherPid, SensorId) ->
	setup_sensor(WatcherPid, SensorId, make_ref()).


setup_sensor(WatcherPid, SensorId, Ref) ->
	Measurement = rand:uniform(11),
	if
		Measurement == 11 ->
			io : format("Measurement == 11, Id: ~w~n", [SensorId]),
			WatcherPid ! {crash, self(), SensorId, anomalous_reading},
			exit(anomalous_reading);
		true ->
			WatcherPid ! {self(), SensorId, Ref, Measurement}
	end,
	receive
		{ok, SensorId, Ref} ->
			Sleep_time = rand:uniform(10000),
		 	timer:sleep(Sleep_time),
		 	setup_sensor(WatcherPid, SensorId, Ref)
	end.