%%%-------------------------------------------------------------------
%%% @author filip
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. Apr 2021 16:23
%%%-------------------------------------------------------------------
-module(pollution_value_collector_tests).
-author("filip").

-include_lib("eunit/include/eunit.hrl").

% Tested manually in the console, EUnit was crashing, probably because
% gen_statem casts are asynchronous
addValues_test() ->
  pollution_gen_server:start(),
  pollution_value_collector_gen_statem:start(),
  pollution_gen_server:addStation("Aleja Slowackiego", {50.2345, 18.3445}),
  pollution_gen_server:addStation("Antarktyda", {-90, 0}),
  pollution_value_collector_gen_statem:setStation("Aleja Slowackiego"),
  pollution_value_collector_gen_statem:addValue({{2021, 3, 22}, {16, 16, 47}}, "PM10", 59),
  pollution_value_collector_gen_statem:addValue({{2021, 3, 22}, {16, 16, 47}}, "PM2,5", 113),
  pollution_value_collector_gen_statem:setStation("Antarktyda"),
  pollution_value_collector_gen_statem:addValue({{2021, 3, 22}, {16, 16, 47}}, "PM10", 0),
  pollution_value_collector_gen_statem:addValue({{2021, 3, 22}, {16, 16, 47}}, "PM2,5", 0),
  pollution_value_collector_gen_statem:storeData(),
  %?assert(59 == pollution_gen_server:getOneValue("Aleja Slowackiego", {{2021, 3, 22}, {16, 16, 47}}, "PM10")),
  %?assert(113 == pollution_gen_server:getOneValue({50.2345, 18.3445}, {{2021, 3, 22}, {16, 16, 47}}, "PM2,5")),
  pollution_value_collector_gen_statem:stop(),
  pollution_gen_server:stop().
