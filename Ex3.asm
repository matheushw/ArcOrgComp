; Matheus Barcellos de Castro Cunha - 11208238       
; Organizacao e Arquitetura de Computadores - SSC0902 

    ORG 100h 
          
Inicio:
    MOV BX,0 ;Zerando o registrador para usa-lo como indexador
    JMP Ate0

Ate0: 
    CMP Vetor1[BX], 0h ;Comparacao para descobrir se chegou no fim do vetor
    JZ Fim ;Caso tenha chegado no fim do vetor
    MOV CX, Vetor1[BX] ;Acessando o valor da BX-esima casa do Vetor1
    MOV DX, Vetor2[BX] ;Acessando o valor da BX-esima casa do Vetor2
    INC BX  
    INC BX  ;Incrementando o indice BX duas vezes, pois estamos lidando com Words
    PUSH BX ;Guardando o valor do possivel proximo indice dos vetores na stack
    DEC BX
    DEC BX  ;Decrementando BX duas vezes para podermos usar o ultimo indice
    CMP CX, DX ;Comparacao usada para ter conhecimento de quem ganhou a rodada
    JZ EmpatouRodada ;Caso os aconteca empate, ninguem leva o ponto e assim pulamos para o proximo indice
    JS Vetor2Maior ;Caso o numero do Vetor2 ganhe a rodada
    JNS Vetor1Maior ;Caso o numero do Vetor1 ganhe a rodada
    
EmpatouRodada: ;Rotina que trata caso de rodada empatada
    POP BX
    JMP Ate0
          
Vetor1Maior: ;Rotina que trata o caso em que o Vetor1 ganha a rodada
    MOV AX, Vetor1[BX] ;Carregando o valor do BX-esimo elemento do vetor em AX, para futuramente inclui-lo no VetorM
    MOV BX, 0h
    CALL PushVetorM ;Chamando rotina para incluir o BX-esimo maior valor, no VetorM
    MOV BX,QtdeV1
    MOV CX,[BX]
    INC CX
    MOV QtdeV1,CX ;Guardando a nova quantidade de rodadas vitoriosas do Vetor1
    POP BX ;Recuperando BX da stack para poder proseguir iterando nos Vetor1 e Vetor2
    JMP Ate0 
    
Vetor2Maior: ;Rotina que trata o caso em que o Vetor2 ganha a rodada     
    MOV AX, Vetor2[BX] ;Carregando o valor do BX-esimo elemento do vetor em AX, para futuramente inclui-lo no VetorM
    MOV BX, 0h
    CALL PushVetorM ;Chamando rotina para incluir o BX-esimo maior valor, no VetorM
    MOV BX,QtdeV2
    MOV CX,[BX]
    INC CX
    MOV QtdeV2,CX ;Guardando a nova quantidade de rodadas vitoriosas do Vetor2
    POP BX ;Recuperando BX da stack para poder proseguir iterando nos Vetor1 e Vetor2
    JMP Ate0
    
PushVetorM: ;Rotina para incluir valor vencedor da rodada, no VetorM
    MOV CX, VetorM[BX]
    INC BX    
    INC BX ;Incrementando BX duas vezes, pois estamos lidando com Words 
    CMP CX, 0h
    JNZ PushVetorM ;Caso o BX-esimo valor do VetorM nao seja 0, devemos contiuar na rotina, pois precisamos chegar no fim do vetor para incluir o novo numero
    DEC BX
    DEC BX ;Decrementando BX duas vezes, pois estamos lidando com Words e precisamos voltar para a ultima posicao valida
    MOV VetorM[BX], AX ;Adicionando o novo numero ao VetorM
    RET
    
Fim: ;Rotina executada quando nao tem mais numeros a serem comparados
    MOV BX, QtdeV1                  
    MOV AX, [BX]
    MOV BX, QtdeV2
    MOV CX, [BX]
    CMP AX, CX  ;Comparacao executada a fim de descobrir o vencedor geral
    JS Vitoria2
    JZ EmpateJogo
    JNS Vitoria1
    
Vitoria1:   ;Caso o vetor 1 tenha uma quantidade maior de numeros maiores
    MOV  DX,GANHOU1
    CALL PrintMsg
    NOP
    RET
                        
Vitoria2:   ;Caso o vetor 2 tenha uma quantidade maior de numeros maiores
    MOV  DX,GANHOU2
    CALL PrintMsg
    NOP
    RET 
    
EmpateJogo: ;Caso o jogo empate
    MOV  DX,EMPATE
    CALL PrintMsg
    NOP
    RET
         
PrintMsg:   ;Usando a interrupcao para printar o resultado geral do jogo
    MOV  AH,09h 
    INT  21h
    RET                                      
    
GANHOU1: DB  "Vetor1 ganhou a disputa $"   
GANHOU2: DB  "Vetor2 ganhou a disputa $" 
EMPATE : DB  "Empatou $"

Vetor1: DW 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 0
Vetor2: DW 15, 5, 35, 45, 55, 25, 35, 85, 95, 1, 0
VetorM: DW 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
QtdeV1: DW 0
QtdeV2: DW 0  

