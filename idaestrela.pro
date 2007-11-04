/*buscaIDA(+Nodo) - Realiza a busca pela solu��o, � partir do Nodo*/
buscaIDA(Nodo) :-
	buscaIDA([Nodo], [], [Nodo], 1, -1).

/*buscaIDA(+Nodo, +Lista de Nos Abertos, +Acumulador) - Realiza a busca pela solu��o, � partir do Nodo, utilizando uma Lista de Nos Abertos e armazenando os resultados no Acumulador*/
buscaIDA([Nodo|Lista], Acumulador, ListaInicial, C, C1) :-
	(eSolucao(Nodo) ->
	 (
	   statistics,
	   %imprimeLista(Lista),
	   eliminaRepeticoes(Lista,ListaU),
	   write('N�mero de elementos na lista de n�s fechados: '),
	   length(Acumulador, TamAcumulador),
	   write(TamAcumulador), nl,
	   write('N�mero de elementos na lista de n�s abertos: '),
	   length(ListaU, TamListaU),
	   write(TamListaU), nl
	 );
	 (
	  naoEstaEm(Nodo, Acumulador),
	  (
	   expandeFilhosIDA(Nodo, Lista, ListaR, C, C1, C2),
	   (
	    ListaR = [E|Lista1] ->
	    (
	     %debugaIDA(Nodo, E, Lista1, C, C2),
	     tentaIDA([E|Lista1], [Nodo|Acumulador], ListaInicial, C, C2)
	    );
	   %N�o consegui pegar o primeiro elemento da lista de n�s abertos. Portanto, ela est� vazia. Temos que recome�ar uma nova itera��o, com o novo valor de C, permitindo aumentar a "abrang�ncia" da busca do algoritmo
	    (
	     C2 =:= -1 -> fail;	%se o C da pr�xima itera��o � infinito (-1), falhamos
	     (
	      %write('Novo C: '),
	      %write(C2), nl,
	      buscaIDA(ListaInicial, [], ListaInicial, C2, -1) % Se h� um C, vamos come�ar tudo de novo com ele
	     )
	    )
	   )
	  )
	 )
	).

/*debuga(+Nodo, +Filho, +NosAbertos, +C, +ProxC) - Para depura��o, imprime um Nodo, seu Filho, a lista de N�s Abertos (NosAbertos), o C da itera��o atual e da pr�xima (ProxC)*/
debugaIDA(Nodo, Filho, NosAbertos, C, ProxC) :-
	write('C: '), write(C), nl,
	write('ProxC: '), write(ProxC), nl,
	imprimeLista([Nodo, Filho|NosAbertos]),
	get_char(_).

/*tentaIDA(+Nodo, +Lista, +Acumulador, +C, +C1) - Tenta realizar a expans�o do Nodo ou vai para o pr�ximo item da Lista, salvando o resultado no Acumulador, utilizando C da itera��o atual e salvando em C1 o da pr�xima itera��o*/
tentaIDA([Nodo], Acumulador, ListaInicial, C, C1) :-
	buscaIDA([Nodo], Acumulador, ListaInicial, C, C1).
tentaIDA([Nodo,Prox|Lista], Acumulador, ListaInicial, C, C1) :-
	(
	 buscaIDA([Nodo,Prox|Lista], Acumulador, ListaInicial, C, C1) ->
	 true;
	 tentaIDA([Prox|Lista], Acumulador, ListaInicial, C, C1)
	).

/*expandeFilhos(+Nodo, +Lista, -ListaR, +C, +C1, -C2) - Expande os filhos do Nodo, colocando-os na Lista, gerando assim, a ListaR. Em C � colocado o C da itera��o atual. Em C1, � colocado o C candidato da pr�xima itera��o. Em C2 � colocado o C da pr�xima itera��o calculado por esse predicado*/
expandeFilhosIDA(Nodo, Lista, ListaR, C, C1, C2) :-
	geraJogadas(Nodo,F1,F2,F3,F4),
	custoCaminho(Nodo,VN),
	
	valorTabuleiro(F1,VF1),
	valorTabuleiro(F2,VF2),
	valorTabuleiro(F3,VF3),
	valorTabuleiro(F4,VF4),
	
	CustoCaminho is VN + 1,
	soma(VF1, CustoCaminho, VTF1),
	soma(VF2, CustoCaminho, VTF2),
	soma(VF3, CustoCaminho, VTF3),
	soma(VF4, CustoCaminho, VTF4),
	
	append(F1,[[CustoCaminho,VTF1]],S1),
	append(F2,[[CustoCaminho,VTF2]],S2),
	append(F3,[[CustoCaminho,VTF3]],S3),
	append(F4,[[CustoCaminho,VTF4]],S4),
	
	elimina(S1, S2, S3, S4, NovoS1, NovoS2, NovoS3, NovoS4, C, C1, C2),
	
	Fs1 = [NovoS1],
	concatsolIDA(Fs1,[NovoS2],Fs2),
	concatsolIDA(Fs2,[NovoS3],Fs3),
	concatsolIDA(Fs3,[NovoS4],Fs4),
	concatsolIDA(Fs4,Lista,ListaNO),
	ordena(ListaNO,ListaR).

/*soma(+Valor1, +Valor2, -Total) - Soma Valor1 com Valor2, colocando o resultado em Total. Se um dos valores for -1, Total � -1*/
soma(-1, _, -1) :- !.
soma(Valor, CustoCaminho, Total) :-
	Total is Valor+CustoCaminho.

/*elimina(+Filho1, +Filho2, +Filho3, +Filho4, -Sobrevivente1, -Sobrevivente2, -Sobrevivente3, -Sobrevivente4, +C, +C1, -NovoC) - � partir do C da itera��o atual, elimina ou n�o Filho1, Filho2, Filho3 e Filho4, salvando o resultado em Sobrevivente1, Sobrevivente2, Sobrevivente3, Sobrevivente4. C1 � a proposta atual do C da pr�xima itera��o e NovoC � a proposta calculada por esse predicado.*/
elimina(Filho1, Filho2, Filho3, Filho4, Sobrevivente1, Sobrevivente2, Sobrevivente3, Sobrevivente4, C, C1, NovoC) :-
	assassino(Filho1, Sobrevivente1, C, C1, C2),
	assassino(Filho2, Sobrevivente2, C, C2, C3),
	assassino(Filho3, Sobrevivente3, C, C3, C4),
	assassino(Filho4, Sobrevivente4, C, C4, NovoC).

/*assassino(+Vitima, +Sobrevivente, +Criterio, +C1, -C2) - � partir do C da itera��o atual (Criterio), elimina ou n�o a Vitima, salvando o resultado em Sobrevivente. C1 � a proposta atual do C da pr�xima itera��o e C2 � a proposta calculada por esse predicado.*/
assassino([[X,-1]], [[X,-1]], _, C1, C1) :- !.
assassino(Vitima, Sobrevivente, Criterio, C1, C2) :-
	valor(Vitima, Valor),
	(
	 Valor =< Criterio ->
	 (
	  Sobrevivente = Vitima,
	  C2 = C1 %Nesse caso, n�o trocamos o valor do pr�ximo C.
	 );
	 (
	  Sobrevivente = [[-1, -1]],
	  min(C1, Valor, C2)
	 )
	).

/*min(+X, +Y, -Min) - Calcula o m�nimo (Min) entre X e Y*/
min(-1, Y, Y) :- !. %-1 � utilizado para indicar infinito
min(X, Y, X) :- X < Y.
min(X, Y, Y) :- Y =< X.

/*concatSolIDA(+Solu��o1, +Solu��o2, -Resultado) - Concatena a Solu��o1 com a Solu��o2, produzindo uma lista em Resultado*/
concatsolIDA(S1,S2,R) :-
	S1 \= [[_]] ->
	(
	 S2 \=[[_]] -> append(S1,S2,R) ;
	 R = S1
	) ;
	(
	 S2 \= [[_]] -> R = S2 ;
	 R = []
	).

/* valor(+Tabuleiro, -Valor) - Retorna o Valor de um Tabuleiro */
valor([_,_,_,_,[_, Valor]],Valor).

/*custoCaminho(+Tabuleiro, -Custo Do Caminho) - Retorna o Custo Do Caminho utilizado para chegar at� esse Tabuleiro*/
custoCaminho([_,_,_,_,[CustoCaminho, _]],CustoCaminho).

/*retornaTabuleiro(+Tabuleiro Com Valores, -Tabuleiro) - Retorna apenas o Tabuleiro, de um Tabuleiro Com Valores*/
retornaTabuleiro([Linha1, Linha2, Linha3, Linha4, [_, _]], [Linha1, Linha2, Linha3, Linha4]).
