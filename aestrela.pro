expandeFilhos(Nodo, Lista, ListaR) :-
	geraJogadas(Nodo,F1,F2,F3,F4),
	custoCaminho(Nodo,VN),
	
	valorTabuleiro(F1,VF1),
	valorTabuleiro(F2,VF2),
	valorTabuleiro(F3,VF3),
	valorTabuleiro(F4,VF4),
	
	CustoCaminho is VN + 1,
	VTF1 is VF1+CustoCaminho,
	VTF2 is VF2+CustoCaminho,
	VTF3 is VF3+CustoCaminho,
	VTF4 is VF4+CustoCaminho,
	
	append(F1,[[CustoCaminho,VTF1]],S1),
	append(F2,[[CustoCaminho,VTF2]],S2),
	append(F3,[[CustoCaminho,VTF3]],S3),
	append(F4,[[CustoCaminho,VTF4]],S4),
	
	Fs1 = [S1],
	concatSol(Fs1,[S2],Fs2),
	concatSol(Fs2,[S3],Fs3),
	concatSol(Fs3,[S4],Fs4),
	concatSol(Fs4,Lista,ListaNO),
	ordena(ListaNO,ListaR).

concatSol(S1,S2,R) :-
	S1 \= [[_]] -> (S2 \= [[_]] -> append(S1,S2,R) ; R = S1) ;
	(S2 \= [[_]] -> R = S2 ; R = [[-1]]).

valor([_,_,_,_,[CustoCaminho, Valor]],Valor).
custoCaminho([_,_,_,_,[CustoCaminho, Valor]],CustoCaminho).
retornaTabuleiro([Linha1, Linha2, Linha3, Linha4, [CustoCaminho, Valor]], [Linha1, Linha2, Linha3, Linha4]).
