%%%-------------------------------------------------------------------
%%% @author filip
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Mar 2021 16:06
%%%-------------------------------------------------------------------
-module(pollution_tests).
-author("filip").

-include_lib("eunit/include/eunit.hrl").

createMonitor_test() ->
  P = pollution:createMonitor(),
  ?assertMatch({monitor, #{}, #{}}, P),
  P.

addStation_test() ->
  P = createMonitor_test(),
  pollution:addStation("Aleja Slowackiego", {50.2345, 18.3445}, P).

addValue_test() ->
  P1 = addStation_test(),
  P2 = pollution:addValue({50.2345, 18.3445}, {{2021,3,22},{16,16,47}}, "PM10", 59, P1),
  pollution:addValue("Aleja Slowackiego", {{2021,3,22},{16,16,47}}, "PM2,5", 113, P2).

getOneValue_test() ->
  P = addValue_test(),
  ?assert(59 == pollution:getOneValue("Aleja Slowackiego", {{2021,3,22},{16,16,47}}, "PM10", P)),
  ?assert(113 == pollution:getOneValue({50.2345, 18.3445}, {{2021,3,22},{16,16,47}}, "PM2,5", P)).

removeValue_test() ->
  P = addValue_test(),
  P1 = pollution:removeValue("Aleja Slowackiego", {{2021,3,22},{16,16,47}}, "PM10", P),
  ?assertError({badkey, _}, pollution:getOneValue("Aleja Slowackiego", {{2021,3,22},{16,16,47}}, "PM10", P1)).

getStationMean_test() ->
  P = addValue_test(),
  ?assertEqual(59.0, pollution:getStationMean("Aleja Slowackiego", "PM10", P)),
  P1 = pollution:addValue("Aleja Slowackiego", {{2021,3,23},{16,16,47}}, "PM10", 61, P),
  ?assertEqual(60.0, pollution:getStationMean("Aleja Slowackiego", "PM10", P1)).

getDailyMean_test() ->
  P = addValue_test(),
  ?assertEqual(59.0, pollution:getDailyMean({2021,3,22}, "PM10", P)),
  P2 = pollution:addStation("Stacja 2", {12,34}, P),
  P3 = pollution:addValue("Stacja 2", {{2021,3,22},{16,16,47}}, "PM5", 61, P2),
  ?assertEqual(59.0, pollution:getDailyMean({2021,3,22}, "PM10", P3)),
  P4 = pollution:addValue("Stacja 2", {{2021,3,22},{16,16,47}}, "PM10", 61, P3),
  ?assertEqual(60.0, pollution:getDailyMean({2021,3,22}, "PM10", P4)).

getClosestStation_test() ->
  P = addValue_test(),
  ?assertEqual("Aleja Slowackiego", pollution:getClosestStation({10,10}, P)),
  P2 = pollution:addStation("Stacja 2", {11,11}, P),
  ?assertEqual("Stacja 2", pollution:getClosestStation({10,10}, P2)),
  ?assertEqual("Aleja Slowackiego", pollution:getClosestStation({50.2345, 18.3445}, P)).

getDailyOverLimit_test() ->
  P = addValue_test(),
  ?assertEqual(1, pollution:getDailyOverLimit({2021,3,22}, "PM10", 40, P)),
  ?assertEqual(0, pollution:getDailyOverLimit({2021,3,22}, "PM10", 60, P)).

changeStationName_test() ->
  P = addValue_test(),
  P2 = pollution:changeStationName("Aleja Slowackiego", "Stacja", P),
  ?assertEqual(59, pollution:getOneValue("Stacja", {{2021,3,22},{16,16,47}}, "PM10", P2)).


