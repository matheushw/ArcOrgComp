; Matheus Barcellos de Castro Cunha - 11208238       
; Organizacao e Arquitetura de Computadores - SSC0902
; Trabalho Pratico 1 - TP1

; Descricao do trabalho:
; - Predio de 8 andares

org 100h

Inicio:
    MOV CL, 5
    JMP CheckBotao
    
CheckBotao:
    MOV BX, Botao_parar_elevador
    MOV AL, [BX]
    CMP AL, 1
    JZ ElevadorParado
    
ChekcDefTarget:    
    MOV BX, ReqQuant
    MOV DL, [BX]
    CMP DL, 0
    JZ CheckTeclado
    
    MOV BX, EmMovimento
    MOV DH, [BX]
    CMP DH, 0
    JZ DefinirTarget
    
CheckTeclado:    
    DEC CL
    JNZ CheckBotao
    MOV AH, 1
    INT 16h
    JNZ InputTeclado
    
ChecGoTarget:    
    MOV BX, Target
    MOV DL, [BX]
    CMP DL, 0
    JNZ GoToTarget 
    JMP Inicio

InputTeclado:
    MOV AH, 0
    INT 16h

CheckPararExecucao:    
    CMP AL, 1bh
    JZ PararExecucao
                   
CheckPararElevador:
    CMP AL, 112
    JZ PararElevador
                   
CheckLivrarElevador:
    CMP AL, 80
    JZ LivrarElevador
    
CheckObsElevador:
    CMP AL, 115
    JZ CheckPorta
                   
CheckDesobsElevador:
    CMP AL, 83
    JZ DesobistruirElevador  
                   
CheckElevadorParado:
    MOV BX, Botao_parar_elevador 
    MOV DL, [BX]
    CMP DL, 1
    JZ Inicio         
                    
IncReqQuant:
    MOV BX, ReqQuant
    MOV CL, [BX]
    INC CL
    MOV ReqQuant, CL
            
CheckComando:
    MOV BX, Sensor_passou_andar
    MOV CL, [BX]
    CMP AL, 61h
    JS ComandoExterno
    JNS ComandoInterno

ComandoInterno:
    SUB AL, 61h
    MOV BH, 0
    MOV BL, AL
    MOV ReqI[BX], 1
    MOV Recebeu_comando, 1
    JMP CheckObstruido

ComandoExterno:
    SUB AL, 31h
    MOV BH, 0
    MOV BL, AL
    MOV ReqE[BX], 1
    MOV Recebeu_comando, 1
    JMP CheckObstruido
    
CheckObstruido:
    MOV BX, Sensos_preseca
    MOV DL, [BX]
    CMP DL, 1
    JZ Obstruido
    JMP Inicio

DefinirTarget:
    MOV Recebeu_comando, 0
    MOV BX, 7
    CALL DefinirTargetLoopE
    MOV BX, Target
    MOV AL, [BX]
    MOV BX, 7
    CMP AL, 0
    JZ DefinirTargetLoopI
    JMP CheckBotao

DefinirTargetLoopE:
    MOV AL, ReqE[BX] 
    CMP AL, 1
    JZ FocusTarget
    DEC BX
    JNS DefinirTargetLoopE
    RET

DefinirTargetLoopI:
    MOV AL, ReqI[BX] 
    CMP AL, 1
    JZ FocusTarget
    DEC BX
    JNS DefinirTargetLoopI
    JMP Inicio

FocusTarget:
    INC BX
    MOV Target, BL
    MOV EmMovimento, 1
    JMP CheckBotao

GoToTarget:  
    MOV BX, Target
    MOV AL, [BX]
    MOV BX, Sensor_passou_andar
    MOV AH, [BX]
    CMP AH, AL
    JZ ChegouTarget
    JMP FecharPorta

ChegouTarget:
    MOV BX, ReqQuant
    MOV AL, [BX]
    DEC AL
    MOV ReqQuant, AL
    MOV BX, Target
    MOV AL, [BX]
    DEC AL
    MOV BH, 0
    MOV BL, AL
    MOV ReqE[BX], 0
    MOV ReqI[BX], 0
    MOV Target, 0
    MOV EmMovimento, 0
    MOV DX, ABREPORTA
    CALL PrintMsg
    MOV Porta_Aberta, 1
    CALL PrintStatus 
    JMP Inicio

SubirAndar:
    MOV BX, Sensor_passou_andar
    MOV CL, [BX]
    INC CL
    MOV Sensor_passou_andar, CL
    CMP CL, 8
    JZ ElevadorNoTopo
    MOV  DX, SUBIU
    CALL PrintMsg
    JMP Inicio

DescerAndar:
    MOV BX, Sensor_passou_andar
    MOV CL, [BX]
    DEC CL
    MOV Sensor_passou_andar, CL
    CMP CL, 1
    JZ ElevadorNaBase
    MOV  DX, DESCEU
    CALL PrintMsg
    JMP Inicio
    
FecharPorta:
    MOV BX,Porta_Aberta
    MOV DL, [BX]
    CMP DL, 1
    JZ PrintFecharPorta
    CALL PrintStatus
    JMP Movimentar
    
Movimentar:
    MOV BX, Target
    MOV AL, [BX]
    MOV BX, Sensor_passou_andar
    MOV AH, [BX]
    CMP AH, AL
    JS SubirAndar
    JNS DescerAndar

Obstruido:
    MOV DX,PORTAOBSTRUIDA
    CALL PrintMsg
    MOV AH, 1
    INT 16h
    JNZ InputTeclado
    JMP Obstruido    

PrintFecharPorta:
    MOV Porta_Aberta, 0   
    MOV DX, FECHAPORTA
    CALL PrintMsg
    JMP FecharPorta
    
ElevadorNoTopo:
    MOV Elevador_no_Topo, 1
    MOV  DX, SUBIU
    CALL PrintMsg
    JMP Inicio

ElevadorNaBase:
    MOV Elevador_na_Base, 1
    MOV  DX, DESCEU
    CALL PrintMsg
    JMP Inicio
    
ElevadorParado: ;Desvio executado caso alguem tenha apertado o botao de parar o elevador
    MOV DX,PARADO
    CALL PrintMsg
    MOV AH, 1
    INT 16h
    JNZ InputTeclado
    JMP ElevadorParado

ObstruirElevador:
    MOV Sensos_preseca, 1
    JMP Obstruido
    
DesobistruirElevador:
    MOV Sensos_preseca, 0
    JMP Inicio

PararElevador: ;Desvio executado quando alguem aperta o botao de parar o elevador
    MOV Botao_parar_elevador, 1
    JMP Inicio
    
LivrarElevador: ;Desvio executado quando alguem aperta o botao de Desbloquear o elevador
    MOV Botao_parar_elevador, 0
    JMP Inicio

PrintMsg:   ;Usando a interrupcao para printar uma cadeia de caracteres
    MOV AH, 09h 
    INT 21h
    RET
    
PrintNwl:   ;Printa quebra de linha
    MOV DX, QUEBRADELINHA 
    MOV AH, 09h 
    INT 21h
    RET
    
PrintStatus:
    CALL PrintAndarStatus
    CALL PrintNwl
                
    CALL PrintStatusCabine
    CALL PrintNwl
                
    MOV BX, 0
    CALL PrintReqI
    CALL PrintNwl
    
    MOV BX, 0
    CALL PrintReqE
    CALL PrintNwl
    
    RET          
    
PrintStatusCabine:
    MOV DX, SITUACAO
    CALL PrintMsg
    MOV BX, Porta_Aberta
    MOV DL, [BX]
    CMP DL, 1 
    JZ PrintPortaAberta
    JMP PrintPortaFechada
           
PrintPortaAberta:
    MOV DX, PORTAABERTA
    CALL PrintMsg
    MOV BX, EmMovimento
    MOV DL, [BX]
    CMP DL, 1
    JZ PrintStatusMovimento
    JMP PrintParado 
    
PrintPortaFechada:
    MOV DX, PORTAFECHADA
    CALL PrintMsg
    MOV BX, EmMovimento
    MOV DL, [BX]
    CMP DL, 1
    JZ PrintStatusMovimento
    JMP PrintParado

PrintParado:
    MOV DX, ELEVPARADO
    CALL PrintMsg
    RET
    
PrintStatusMovimento:
    MOV DX, MOVENDOPARA
    CALL PrintMsg
    MOV BX, Target
    MOV BX, [BX]
    DEC BX
    CALL PrintNumeroAndar
    RET 

PrintReqI:
    MOV DX, LISTREQI
    CALL PrintMsg
    JMP LoopPrintReqI  

LoopPrintReqI:   
    MOV DL, ReqI[BX]
    CMP DL, 1
    JZ PrintRequestAndarI
    INC BX
    CMP BX, 8
    JNZ LoopPrintReqI
    RET

PrintRequestAndarI:
    CALL PrintNumeroAndar
    INC BX
    CMP BX, 8
    JNZ LoopPrintReqI
    RET
    
PrintReqE:
    MOV DX, LISTREQE
    CALL PrintMsg
    JMP LoopPrintReqE
    
LoopPrintReqE:   
    MOV DL, ReqE[BX]
    CMP DL, 1
    JZ PrintRequestAndarE
    INC BX
    CMP BX, 8
    JNZ LoopPrintReqE
    RET

PrintRequestAndarE:
    CALL PrintNumeroAndar
    INC BX
    CMP BX, 8
    JNZ LoopPrintReqE
    RET       
    
PrintNumeroAndar:
    MOV AL, BL
    INC AL
    ADD AL, 30h
    MOV AH, 0eh
    INT 10h
    MOV DX, BLANKSPACE
    CALL PrintMsg
    RET
    
PrintAndarStatus:
    MOV DX, PASSOUANDAR
    CALL PrintMsg
    MOV BX, Sensor_passou_andar
    MOV AL, [BX]
    ADD AL, 30h
    MOV AH, 0eh
    INT 10h
    RET

CheckPorta:
    MOV BX, Porta_Aberta
    MOV DL, [BX]
    CMP DL, 1
    JZ ObstruirElevador
    JMP CheckDesobsElevador

PararExecucao:
    NOP
    RET

ReqE: DB 0, 0, 0, 0, 0, 0, 0, 0
ReqI: DB 0, 0, 0, 0, 0, 0, 0, 0
Botao_parar_elevador: DB 0
Elevador_na_Base: DB 0
Elevador_no_Topo: DB 0
Porta_Aberta: DB 1
Sensos_preseca: DB 0 ;Implementar
Sensor_passou_andar: DB 1
Recebeu_comando: DB 0
EmMovimento: DB 0
Target: DB 0
ReqQuant: DB 0
FlagRegQuant: DB 0

SUBIU: DB "Move para cima", 0Dh,0Ah, "$" 
DESCEU: DB "Move para baixo", 0Dh,0Ah, "$"
ABREPORTA: DB "Abre Porta", 0Dh,0Ah, "$"
FECHAPORTA: DB "Fecha Porta", 0Dh,0Ah, "$"
PARADO: DB "Elevador parado", 0Dh,0Ah, "$"
PORTAOBSTRUIDA: DB "Porta Obstruida", 0Dh,0Ah, "$"

PORTAABERTA: DB "Porta Aberta, $"
PORTAFECHADA: DB "Porta Fechada, $"
ELEVPARADO: DB "Parado $"
MOVENDOPARA: DB "Movendo para o andar $"
                                              
QUEBRADELINHA: DB 0Dh,0Ah,"$"
PASSOUANDAR: DB "Andar Atual -> $"
SITUACAO: DB "Situacao da cabine -> $"
LISTREQE: DB "Lista de requisicoes externas -> $"
LISTREQI: DB "Lista de requisicoes internas -> $"
BLANKSPACE: DB " $"