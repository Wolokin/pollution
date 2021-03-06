%%%-------------------------------------------------------------------
%%% @author filip
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%% Just some basic api tests, these are tests used in pollution_tests but using pollution_server api
%%% @end
%%% Created : 05. Apr 2021 12:49
%%%-------------------------------------------------------------------
-module(pollution_server_tests).
-author("filip").

-include_lib("eunit/include/eunit.hrl").

initTest() ->
  pollution_server:start(),
  pollution_server:addStation("Aleja Slowackiego", {50.2345, 18.3445}),
  pollution_server:addValue({50.2345, 18.3445}, {{2021, 3, 22}, {16, 16, 47}}, "PM10", 59),
  pollution_server:addValue("Aleja Slowackiego", {{2021, 3, 22}, {16, 16, 47}}, "PM2,5", 113).

endTest() ->
  pollution_server:stop().

startStopServer_test() ->
  pollution_server:start(),
  pollution_server:stop().

addStation_test() ->
  pollution_server:start(),
  pollution_server:addStation("Aleja Slowackiego", {50.2345, 18.3445}),
  pollution_server:stop().

addValue_test() ->
  pollution_server:start(),
  pollution_server:addStation("Aleja Slowackiego", {50.2345, 18.3445}),
  pollution_server:addValue({50.2345, 18.3445}, {{2021, 3, 22}, {16, 16, 47}}, "PM10", 59),
  pollution_server:addValue("Aleja Slowackiego", {{2021, 3, 22}, {16, 16, 47}}, "PM2,5", 113),
  pollution_server:stop().

getOneValue_test() ->
  initTest(),
  ?assert(59 == pollution_server:getOneValue("Aleja Slowackiego", {{2021, 3, 22}, {16, 16, 47}}, "PM10")),
  ?assert(113 == pollution_server:getOneValue({50.2345, 18.3445}, {{2021, 3, 22}, {16, 16, 47}}, "PM2,5")),
  endTest().

removeValue_test() ->
  initTest(),
  pollution_server:removeValue("Aleja Slowackiego", {{2021, 3, 22}, {16, 16, 47}}, "PM10"),
  %% Nie wiem jak assertowac bledy w innych watkach
  % ?assertError({badkey, _}, pollution_server:getOneValue("Aleja Slowackiego", {{2021,3,22},{16,16,47}}, "PM10")),
  endTest().

getStationMean_test() ->
  initTest(),
  ?assertEqual(59.0, pollution_server:getStationMean("Aleja Slowackiego", "PM10")),
  pollution_server:addValue("Aleja Slowackiego", {{2021, 3, 23}, {16, 16, 47}}, "PM10", 61),
  ?assertEqual(60.0, pollution_server:getStationMean("Aleja Slowackiego", "PM10")),
  endTest().

getDailyMean_test() ->
  initTest(),
  ?assertEqual(59.0, pollution_server:getDailyMean({2021, 3, 22}, "PM10")),
  pollution_server:addStation("Stacja 2", {12, 34}),
  pollution_server:addValue("Stacja 2", {{2021, 3, 22}, {16, 16, 47}}, "PM5", 61),
  ?assertEqual(59.0, pollution_server:getDailyMean({2021, 3, 22}, "PM10")),
  pollution_server:addValue("Stacja 2", {{2021, 3, 22}, {16, 16, 47}}, "PM10", 61),
  ?assertEqual(60.0, pollution_server:getDailyMean({2021, 3, 22}, "PM10")),
  endTest().

getClosestStation_test() ->
  initTest(),
  ?assertEqual("Aleja Slowackiego", pollution_server:getClosestStation({10, 10})),
  pollution_server:addStation("Stacja 2", {11, 11}),
  ?assertEqual("Stacja 2", pollution_server:getClosestStation({10, 10})),
  ?assertEqual("Aleja Slowackiego", pollution_server:getClosestStation({50.2345, 18.3445})),
  endTest().

getDailyOverLimit_test() ->
  initTest(),
  ?assertEqual(1, pollution_server:getDailyOverLimit({2021, 3, 22}, "PM10", 40)),
  ?assertEqual(0, pollution_server:getDailyOverLimit({2021, 3, 22}, "PM10", 60)),
  endTest().

changeStationName_test() ->
  initTest(),
  pollution_server:changeStationName("Aleja Slowackiego", "Stacja"),
  ?assertEqual(59, pollution_server:getOneValue("Stacja", {{2021, 3, 22}, {16, 16, 47}}, "PM10")),
  endTest().