% randelem(+list,?elem)
randelem(L,X) :- length(L,LL), I is random(LL), nth0(I,L,X).

% selandrem(+index,+list,-list,-elem)
selandrem0(0,[X|R],R,X) :- !.
selandrem0(I,[A|R],[A|Rout],X) :- NI is I-1, selandrem0(NI,R,Rout,X).

% just a helper function to boggleboard, below
% bbhelp(-board,+nleft,+cubes)
bbhelp([],0,[]) :- !.
bbhelp([X|R],L,CS) :- I is random(L), selandrem0(I,CS,NCS,C), randelem(C,X), !,
				NL is L-1, bbhelp(R,NL,NCS).

% returns a randomly chosen boggle board.
% No choice points -- will not backtrack
% boggleboard(-board)
boggleboard(B) :- bbhelp(B,16,
		[['A','A','E','E','G','N'],['A','B','B','J','O','O'],
		 ['A','C','H','O','P','S'],['A','F','F','K','P','S'],
		 ['A','O','O','T','T','W'],['C','I','M','O','T','U'],
		 ['D','E','I','L','R','X'],['D','E','L','R','V','Y'],
		 ['D','I','S','T','T','Y'],['E','E','G','H','N','W'],
		 ['E','E','I','N','S','U'],['E','H','R','T','V','W'],
		 ['E','I','O','S','S','T'],['E','L','R','T','T','Y'],
		 ['H','I','M','N','Q','U'],['H','L','N','N','R','Z']]).

% boggleletter(+board,?xindex,?yindex,?character)
boggleletter(B,X,Y,C) :- nth0(N,B,C), XR is N/4, X is floor(XR), Y is mod(N,4).

%flagReplace(+List,+Index, -NewList)
%finds and replaces the thing at the specified index with false. Used to mark which letters were used.
flagReplace([_|T],0,[false|T]).
flagReplace([H|T],Index,[H|T2]) :- Index > 0, Index2 is Index-1, flagReplace(T,Index2,T2).

%newFlag(-List).
%Make a new flag list to correspond to the current word's used letters.
newFlag([true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]).

%flagBoard(+X,+Y,?Flag)
%An array of 16 booleans. If Flag is bound, set the corresponding spot in the array to that flag. If it's not bound, succeed if it's true at that location.
flagFind([H|T],0) :- H.
flagFind([_|T], Index) :- Index2 is Index-1, flagFind(T, Index2).

%getIndex(+X,+Y,-Index)
%Put X and Y coordinates in to get the corresponding index (used for flags)
getIndex(0,0,0).
getIndex(1,0,1).
getIndex(2,0,2).
getIndex(3,0,3).
getIndex(0,1,4).
getIndex(1,1,0).
getIndex(2,1,0).
getIndex(3,1,0).
getIndex(0,2,0).
getIndex(1,2,0).
getIndex(2,2,0).
getIndex(3,2,0).
getIndex(0,3,0).
getIndex(1,3,0).
getIndex(2,3,0).
getIndex(3,3,0).



%isboggleword(+board,+dictionary,?word)
%If word is bound, tries to find the word on the board. If word is unbound, find all words.
isboggleword(B, node(Char,true,_,_) ,[Char]) :- boggleletter(B,_,_,Char). %If there's only one letter left, and it is true in the dictionary, find it on the board.
isboggleword(B, node(Char,_,Down,Side) ,[Char,Next|Rest]) :- isAdj(B,Char,Next), boggleletter(B,_,_,Char), isboggleword(B,Down,[Next|Rest]). %Find if there is a character matching Next that's adjacent to Char. If so, add Char to the word being made and recurse on the down subtree with Next.
isboggleword(B, node(_,_,_,Left) ,[Char|Rest]) :- isboggleword(B,Left,[Char|Rest]). %If it got to this point, the Char wasn't found in this part of the tree. Whether it's on the board isn't relevant (if there are no words that start with let's say 'x', it doesn't matter if it's on the board or not.) Continue left through the dict to find the letter.

%isAdj(+B,+Char,+Next)
%Get the coordinates of Char, then check if Next has coordinates at any of the 8 adjacent squares.
isAdj(B,Char,Next) :- boggleletter(B,X,Y,Char), boggleletter(B,X2,Y,Next), X2 =:= X+1. %Right
isAdj(B,Char,Next) :- boggleletter(B,X,Y,Char), boggleletter(B,X,Y2,Next), Y2 =:= Y+1. %up
isAdj(B,Char,Next) :- boggleletter(B,X,Y,Char), boggleletter(B,X2,Y2,Next), X2 =:= X+1, Y2 =:= Y+1. %Upright
isAdj(B,Char,Next) :- boggleletter(B,X,Y,Char), boggleletter(B,X2,Y,Next), X2 =:= X-1. %left
isAdj(B,Char,Next) :- boggleletter(B,X,Y,Char), boggleletter(B,X,Y2,Next), Y2 =:= Y-1. %down
isAdj(B,Char,Next) :- boggleletter(B,X,Y,Char), boggleletter(B,X2,Y2,Next), X2 =:= X-1, Y2 =:= Y-1. %Downleft
isAdj(B,Char,Next) :- boggleletter(B,X,Y,Char), boggleletter(B,X2,Y2,Next), X2 =:= X+1, Y2 =:= Y-1.%downright
isAdj(B,Char,Next) :- boggleletter(B,X,Y,Char), boggleletter(B,X2,Y2,Next), X2 =:= X-1, Y2 =:= Y+1.%upleft

% you should not use this... you will need to traverse the dictionary
% yourself.  However, this checks whether the first argument (a list of
% characters) is in the dictionary (the second argument)
% order it adds the word to the dictionary
% indict(?word,?dictionary)
indict([X],node(X,true,_,_)).
indict([X|RX],node(X,_,Y,_)) :- indict(RX,Y).
indict([X|RX],node(_,_,_,Y)) :- indict([X|RX],Y).

% a helper function to loaddict, below
loaddicthelp(S,_) :- at_end_of_stream(S), !.
loaddicthelp(S,D) :- read_line_to_codes(S,C), atom_codes(Str,C),
		atom_chars(Str,W), indict(W,D), !, loaddicthelp(S,D).

% a helper function to loaddict, only succeeds if the dictionary is grounded.
restrictdict(null) :- !.
restrictdict(node(_,false,L,R)) :- !, restrictdict(L), !, restrictdict(R).
restrictdict(node(_,true,L,R)) :- !, restrictdict(L), !, restrictdict(R).

% loads a dictionary
% loaddict(+filename,-dictionary)
loaddict(Filename,Dict) :- 
	open(Filename,read,S), !,
	loaddicthelp(S,Dict), !, 
	restrictdict(Dict),
	close(S).

% draws a boggle board 
% drawboard(+board).
drawboard(B) :- drawboard(B,16).
drawboard(_,0) :- !.
drawboard([X|Y],I) :- 1 =:= mod(I,4), !, writeln(X),
		II is I-1, drawboard(Y,II).
drawboard([X|Y],I) :- write(X), II is I-1, drawboard(Y,II).



% word is a list of characters
% boggleword(+board,?word)
boggleword(B,X) :- loaddict(bogwords,D), isboggleword(B,D,X).


% below is only needed for Q3
%---------------------
removedup([],[]).
removedup([H|T], List) :- member(H,T), removedup(T,List).
removedup([H|T], [H|T2]) :- \+member(H,T), removedup(T,T2).

% converttostr(?listlistchar,?liststr)
converttostr([],[]).
converttostr([X|XR],[Y|YR]) :- atom_chars(Y,X), converttostr(XR,YR).

% allbogglewords(+board,-words)
allbogglewords(B,X) :- loaddict(bogwords,D),
	findall(W,isboggleword(B,D,W),XL),
	removedup(XL,XL2), converttostr(XL2,X).

