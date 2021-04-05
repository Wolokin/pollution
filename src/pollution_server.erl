-module(pollution_server).
-author("Filip").

-export([start/0, stop/0, call/1]).

start() ->
  erlang:register(pollutionServer, spawn(fun init/0)).

stop() ->
  call(exit).

init() ->
  EmptyMonitor = pollution:createMonitor(),
  loop(EmptyMonitor).

call(Message) ->
  pollutionServer ! {request, erlang:self(), Message},
  receive
    {reply, Reply} -> Reply
  end.

loop(Monitor) ->
  receive
    {request, Pid, {addStation, {Name, Coords}}} ->
      UpdatedMonitor = pollution:addStation(Name, Coords, Monitor),
      Pid ! {reply, ok},
      loop(UpdatedMonitor);
    {request, Pid, {addValue, {Station, Datetime, MeasurementType, Value}}} ->
      UpdatedMonitor = pollution:addValue(Station, Datetime, MeasurementType, Value, Monitor),
      Pid ! {reply, ok},
      loop(UpdatedMonitor);
    {request, Pid, {removeValue, {Station, Datetime, MeasurementType}}} ->
      UpdatedMonitor = pollution:removeValue(Station, Datetime, MeasurementType, Monitor),
      Pid ! {reply, ok},
      loop(UpdatedMonitor);
    {request, Pid, {getOneValue, {Station, Datetime, MeasurementType}}} ->
      Value = pollution:getOneValue(Station, Datetime, MeasurementType, Monitor),
      Pid ! {reply, Value},
      loop(Monitor);
    {request, Pid, {getStationMean, {Station, MeasurementType}}} ->
      Value = pollution:getStationMean(Station, MeasurementType, Monitor),
      Pid ! {reply, Value},
      loop(Monitor);
    {request, Pid, {getDailyMean, {Date, MeasurementType}}} ->
      Value = pollution:getDailyMean(Date, MeasurementType, Monitor),
      Pid ! {reply, Value},
      loop(Monitor);
    {request, Pid, {getDailyOverLimit, {Date, MeasurementType, Norm}}} ->
      Value = pollution:getDailyOverLimit(Date, MeasurementType, Norm, Monitor),
      Pid ! {reply, Value},
      loop(Monitor);
    {request, Pid, {getClosestStation, {Coords}}} ->
      Value = pollution:getClosestStation(Coords, Monitor),
      Pid ! {reply, Value},
      loop(Monitor);
    {request, Pid, {changeStationName, {OldName, NewName}}} ->
      UpdatedMonitor = pollution:changeStationName(OldName, NewName, Monitor),
      Pid ! {reply, ok},
      loop(UpdatedMonitor);
    {request, Pid, exit} ->
      Pid ! {reply, ok}
  end.