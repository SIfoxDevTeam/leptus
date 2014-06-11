%% The MIT License
%%
%% Copyright (c) 2013-2014 Sina Samavati <sina.samv@gmail.com>
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%% THE SOFTWARE.

-module(leptus_access_log).
-behaviour(gen_event).

%% -----------------------------------------------------------------------------
%% gen_event callbacks
%% -----------------------------------------------------------------------------
-export([init/1]).
-export([handle_event/2]).
-export([handle_call/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-define(FILENAME_SUFFIX, "-access.log").
-define(LOG_FORMAT, "~h ~l ~u ~t \"~r\" ~s ~B \"~{referer}\" \"~{user-agent}\"").

init(Dir) ->
    Filename = filename(Dir),
    filelib:ensure_dir(Filename),
    {ok, IoDev} = file:open(Filename, [append]),
    {ok, IoDev}.

handle_event({access_log, LogData}, IoDev) ->
    Log = leptus_logger:format(?LOG_FORMAT, LogData),
    file:write(IoDev, [Log, $\n]),
    {ok, IoDev};
handle_event(_, IoDev) ->
    {ok, IoDev}.

handle_call(_Request, IoDev) ->
    {ok, IoDev}.

handle_info(_Info, State) ->
    {ok, State}.

terminate(_Args, IoDev) ->
    file:close(IoDev),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

filename(Dir) ->
    {{Y, M, D}, _} = erlang:localtime(),
    filename:join(Dir, io_lib:format("~w_~2..0w_~2..0w~s",
                                     [Y, M, D, ?FILENAME_SUFFIX])).
