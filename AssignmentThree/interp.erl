-module(interp).
-export([scanAndParse/1,runFile/1,runStr/1]).
-include("types.hrl").
-author("Shengjie HU").

loop(InFile,Acc) ->
    case io:request(InFile,{get_until,prompt,lexer,token,[1]}) of
        {ok,Token,_EndLine} ->
            loop(InFile,Acc ++ [Token]);
        {error,token} ->
            exit(scanning_error);
        {eof,_} ->
            Acc
    end.

scanAndParse(FileName) ->
    {ok, InFile} = file:open(FileName, [read]),
    Acc = loop(InFile,[]),
    file:close(InFile),
    {Result, AST} = parser:parse(Acc),
    case Result of 
	ok -> AST;
	_ -> io:format("Parse error~n")
    end.


-spec runFile(string()) -> valType().
runFile(FileName) ->
    valueOf(scanAndParse(FileName),env:new()).

scanAndParseString(String) ->
    {_ResultL, TKs, _L} = lexer:string(String),
    parser:parse(TKs).

-spec runStr(string()) -> valType().
runStr(String) ->
    {Result, AST} = scanAndParseString(String),
    case Result  of 
    	ok -> valueOf(AST,env:new());
    	_ -> io:format("Parse error~n")
    end.


-spec numVal2Num(numValType()) -> integer().
numVal2Num({num, N}) ->
    N.

-spec boolVal2Bool(boolValType()) -> boolean().
boolVal2Bool({bool, B}) ->
    B.

-spec valueOf(expType(),envType()) -> valType().
valueOf(Exp,Env) ->
    case Exp of
        %% element -> atom : '$1'.
        %{diffExp, '$3', '$5'}.
        %{plusExp, '$3', '$5'}.
        %{ifThenElseExp, '$2', '$4', '$6'}.
        %{letExp, '$2', '$4', '$6'}.
        %{procExp, '$3', '$5'}.
        %{isZeroExp, '$3'}

        % {numExp, {num, 1, number}}
        {numExp, {num, 1, Val}} -> 
            {num, Val};
        % {idExp, {id, 1, identifier}}
        {idExp, {id, 1, Id}} ->
            env:lookup(Env, Id);
        % {diffExp, leftExp, rightExp}
        {diffExp, LeftExp, RightExp} ->
            {num, numVal2Num(valueOf(LeftExp, Env)) -
                    numVal2Num(valueOf(RightExp, Env))};

        {plusExp, LeftExp, RightExp} ->
            {num, numVal2Num(valueOf(LeftExp, Env)) -
                    numVal2Num(valueOf(RightExp, Env))};
        {isZeroExp, NumExp} ->
            Num = numVal2Num(valueOf(NumExp, Env)),
            if
                Num == 0 -> 
                    {bool, true};
                true -> 
                    {bool, false} end;

        {ifThenElseExp, IndexExp, TrueExp, FalseExp} ->
            Condition = boolVal2Bool(valueOf(IndexExp, Env)),
            if  
                Condition == true ->
                    valueOf(TrueExp, Env);
                true ->
                    valueOf(FalseExp, Env) end;
        %(expression
        %("let" identifier "=" expression "in" expression)
        %    let-exp)  
        %{ok,{letExp,{id,1,y},
        %   {numExp ,{num ,1,3}},
        %   {plusExp,{numExp,{num,1,2}},{idExp,{id,1,y}}}}} 
        {letExp, {id, 1, X}, ValExp, InExp} -> 
            UpdateEnv = env:add(Env, X, valueOf(ValExp, Env)),
            valueOf(InExp, UpdateEnv);
        %"proc (x) +(x,3)".
        %{proc,x,
        %{plusExp,{idExp,{id,1,x}},{numExp,{num,1,3}}}, {dict ,0,16,16,8,80,48,
        %{[],[],[],[],[],[],[],[],[],[],[],[],[],[] ,...}, {{[],[],[],[],[],[],[],[],[],[],[],[] ,...}}}},
        {procExp, {id, 1, Id}, MainExp} ->
            {proc, Id, MainExp, Env};
        %{appExp,{idExp,{id,1,y}},{numExp,{num,1,5}}}
        %add(Env,Key,Value)
        %-type procValType() :: { proc, atom(), expType(), envType()}.
        {appExp, IdExp, ValExp} ->
            %{_, Val} = valueOf(IdExp, Env),
            {_, Id, Exptype, Envtype} = valueOf(IdExp, Env),
            UpdateEnv = env:add(Env, Id, valueOf(ValExp, Envtype)),
            valueOf(Exptype, UpdateEnv)
    end.


    %% complete
