-module(makeup).
-compile(export_all).

readlines(FileName) ->
	SensorList = [],
	SensorId = spawn(?MODULE, allSensors, [SensorList]),
	NameDict = dict:new(),
	NameId = spawn(?MODULE, nameSensor, [NameDict]),
	spawn(makeup,updateFunction,[NameId]),
	{ok, Device} = file:open(FileName , [read]),
	try get_all_lines(Device, SensorId, NameId)
		after file:close(Device)
	end,
		SensorId!{overTime}.

get_all_lines(Device, SensorId, NameId) ->
	case io:get_line(Device , "") of
		eof -> [];
		Line -> Ss=string:tokens(Line,",\n"),
			io:fwrite(" head ~s tail ~s ~n",[hd(Ss),tl(Ss)]),
			Pid = spawn(?MODULE, sensorPro, [hd(Ss), updataNameId, 0, 0, tl(Ss)]),
			SensorId ! {new, Pid},
			NameId ! {Pid, hd(Ss)},
			[{hd(Ss),tl(Ss)}] ++ get_all_lines(Device, SensorId, NameId) 
	end.

allSensors(SensorList) ->
	receive
		{new, NewPid} ->
			allSensors(lists:concat([[NewPid], SensorList]));
		{overTime} ->
			TimerP = spawn(?MODULE, timer,[SensorList]),
			timer:kill_after(30000,TimerP)
	end.

nameSensor(NameDict) ->
	receive
		{Pid, NameStr} ->
			nameSensor(dict:store(NameStr, Pid, NameDict));
		{request, From, NameStr} ->
			From ! {result, dict:fetch(NameStr, NameDict)},
			nameSensor(NameDict)
	end.
	
sensorPro(Pid, KeyWords, Sum, Num, NBHD) ->
	receive
		{tick} ->
			io:fwrite("Pid ~w is ticked ~n",[Pid]),
			if
				Num == 0 ->
					sensorPro(Pid, KeyWords, Sum, Num, NBHD);
				Num /= 0 ->
					send(Pid, KeyWords, NBHD, Sum/Num),
					io:fwrite("Pid ~w Val ~w ~n", [Pid, Sum/Num]),
					sensorPro(Pid, KeyWords, Sum, Num, NBHD)
			end;
		{update, Pid, UpdateVal} ->
			NewPid = spawn(sensorPro(Pid,KeyWords,UpdateVal,1,NBHD)),
 			KeyWords!{NewPid,Pid};
		{nbhd, Val} ->
			NewPid = spawn(sensorPro(Pid,KeyWords,Sum + Val,Num + 1,NBHD)),
 			KeyWords!{NewPid,Pid}
 	end.

timer(SenID) ->
	timer:sleep(5000),
	sendTick(SenID),
	timer(SenID).

sendTick(SenID) ->
	[PidOfSen | Tail] = SenID,
	PidOfSen ! {tick},
	io:fwrite("Sensor ~w ready to be ticked ~n",[PidOfSen]),
	if 
		Tail == [] -> 
			stop;
		Tail /= [] ->
			sendTick(Tail)
	end.

updateFunction(NameId) ->   %nameSensor
	register(updataNameId, NameId),
	timer:sleep(30000),
	unregister(updataNameId).



directReading(Pid,UpdatedVal) ->
	io:fwrite("set ~w to ~w ~n",[Pid, UpdatedVal]),
	updataNameId!{request,self(),Pid},
	receive
		{result,ProPid}	->
			io:fwrite("pripid = ~w~n", [ProPid]),
			ProPid!{update,Pid,UpdatedVal}
	end.



send(Pid, KeyWords, NBHD, Val) ->
	[NameOfReceiver|Tail] = NBHD,
	KeyWords ! {request, self(), NameOfReceiver},
	receive
		{result, PidOfReceiver} ->
			io:fwrite("Msg ~w from ~w to ~w ~n", [Val, Pid, NameOfReceiver]),
			PidOfReceiver ! {nbhd, Val}
	end,
	if
		Tail == [] ->
			io:fwrite("Msg ~w from ~w to ~w finished ~n", [Val, Pid, NameOfReceiver]);
		Tail /= [] ->
			io:fwrite("Sending~n"),
			timer:sleep(100),
			send(Pid, KeyWords, Tail, Val)
	end.






