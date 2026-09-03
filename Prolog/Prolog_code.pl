% Name: Colin Nartey


%command to run: "/Applications/SWI-Prolog.app/Contents/MacOS/swipl" prolog_solution.pl

% dynamic database

:- dynamic piece/3. % piece(row, column, color)
:- dynamic turn/1.     % turn(Player)
:- dynamic ability/2.   % ability(Player, Type) whether its white or black and whether or not its a skip or move ability.
:- dynamic cooldown/2.   % cooldown(row, column)
:- dynamic skip_active/1.  % skip_active ?(Boolean)

% game setup
start :-
    retractall(piece(_,_,_)),
    retractall(turn(_)),
    retractall(ability(_,_)),
    retractall(cooldown(_,_)),
    retractall(skip_active(_)),
    
    % starting game info
    assert(turn(w)),
    assert(skip_active(false)),
    
    % places the pieces (white pieces on rows 5-7, black pieces on rows 0-2)
    setup_pieces(0, 0),
    
    write(' 23666305 - Starting  Game...'), nl,
    play_turn.

% recursive setup 
setup_pieces(8, _) :- !. % stop at row 8
setup_pieces(R, C) :-
    (C > 7 -> NextR is R + 1, setup_pieces(NextR, 0);
     (odd_square(R, C), R < 3) -> assert(piece(R, C, b)), NextC is C + 1, setup_pieces(R, NextC);
     (odd_square(R, C), R > 4) -> assert(piece(R, C, w)), NextC is C + 1, setup_pieces(R, NextC);
     NextC is C + 1, setup_pieces(R, NextC)).

odd_square(R, C) :- Sum is R + C, 1 is Sum mod 2.

% Prints the board
print_board :-
    turn(P),
    format('~nTurn Player: ~w~n', [P]),
    write('  0 1 2 3 4 5 6 7'), nl,
    print_rows(0).

print_rows(8) :- !.
print_rows(R) :-
    write(R), write(' '),
    print_cols(R, 0),
    nl,
    NextR is R + 1,
    print_rows(NextR).

print_cols(_, 8) :- !.
print_cols(R, C) :-
    (piece(R, C, Color) -> write(Color), write(' '); write('. '), write('')),
    NextC is C + 1,
    print_cols(R, NextC).

% Game functionality and abilities
play_turn :-
    print_board,
    write('Choose (m)ove, (s)kip ability, (a)bility to move opponent: '),
    read(Choice),
    handle_choice(Choice).

% standard piece movement
handle_choice(m) :-
    write('From row: '), read(R1),
    write('From col: '), read(C1),
    write('To row: '), read(R2),
    write('To col: '), read(C2),
    turn(Player),
    
    (valid_move(R1, C1, R2, C2, Player) ->
        execute_move(R1, C1, R2, C2),
        switch_turn,
        play_turn
    ;
        write('Invalid move or cooldown!'), nl,
        play_turn
    ).

% skip abilitiy
handle_choice(s) :-
    turn(Player),
    (ability(Player, skip) -> 
        write('Ability already used!'), nl, play_turn
    ;
        write('Skip Activated! Make your first move now.'), nl,
        write('Move 1 From row: '), read(R1),
        write('Move 1 From col: '), read(C1),
        write('Move 1 To row: '), read(R2),
        write('Move 1 To col: '), read(C2),
        
        execute_move(R1, C1, R2, C2),
        assert(ability(Player, skip)), % Mark as used
        assert(skip_active(true)),     % Set flag to skip next switch
        switch_turn,                   % This will see the flag and NOT switch player
        play_turn
    ).

% move opponent piece ability
handle_choice(a) :-
    turn(Player),
    (ability(Player, move_opp) ->
        write('Ability already used!'), nl, play_turn
    ;
        write('Opponent piece row: '), read(R1),
        write('Opponent piece col: '), read(C1),
        write('Target row: '), read(R2),
        write('Target col: '), read(C2),
        
        (piece(R1, C1, TargetColor), TargetColor \= Player ->
            move_piece_fact(R1, C1, R2, C2, TargetColor), % move without validation rules
            assert(ability(Player, move_opp)),
            assert(cooldown(R2, C2)), % freeze piece
            switch_turn,
            play_turn
        ;
            write('Not an opponent piece!'), nl, play_turn
        )
    ).

% game functions code:

% checks if a standard move is valid to be made
valid_move(R1, C1, R2, C2, Player) :-
    piece(R1, C1, Player),   % piece must belong to player
    \+ piece(R2, C2, _),   % target must be empty
    \+ cooldown(R1, C1),   % piece must not be frozen
    R2 >= 0, R2 < 8, C2 >= 0, C2 < 8.

% updates the database by removing the old state and adding the new one
execute_move(R1, C1, R2, C2) :-
    piece(R1, C1, Color),
    move_piece_fact(R1, C1, R2, C2, Color),
    check_king(R2, Color).

move_piece_fact(R1, C1, R2, C2, Color) :-
    retract(piece(R1, C1, Color)),
    assert(piece(R2, C2, Color)).

% promotes pieces to king
check_king(0, w) :- retract(piece(0, _, w)), assert(piece(0, _, wk)).
check_king(7, b) :- retract(piece(7, _, b)), assert(piece(7, _, bk)).
check_king(_, _). % if not on the king row, then do nothing

% switches turns
switch_turn :-
    skip_active(true), !,  %checks if skip is active
    write('Opponent skipped! It is still your turn.'), nl,
    retract(skip_active(true)),
    assert(skip_active(false)).  % reset skip_active to false, keep same player.

switch_turn :-
    turn(w), !,
    retract(turn(w)), assert(turn(b)),
    reduce_cooldowns.

switch_turn :-
    turn(b), !,
    retract(turn(b)), assert(turn(w)),
    reduce_cooldowns.

reduce_cooldowns :-
    retractall(cooldown(_,_)). % clears all cooldowns on turn switch
