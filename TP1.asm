; Matheus Barcellos de Castro Cunha - 11208238       
; Organizacao e Arquitetura de Computadores - SSC0902
; Trabalho Pratico 1 - TP1

; Descricao do trabalho:
; - Predio de 8 andares

org 100h

Inicio:
    MOV CL, 10
    JMP RotinaPrincipal

RotinaPrincipal:
    MOV BX, Target
    MOV DL, [BX]
    CMP DL, 0
    JNZ GoToTarget
    
    MOV BX, Recebeu_comando
    MOV DL, [BX]
    CMP DL, 0
    JNZ DefinirTarget
    
    DEC CL
    JNZ RotinaPrincipal
    MOV AH, 1
    INT 16h
    JNZ InputTeclado
    
    
    JMP Inicio
    

InputTeclado:
    MOV AH, 0
    INT 16h
    CMP AL, 1bh
    JZ PararExecucao
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
    JMP Inicio

ComandoExterno:
    SUB AL, 31h
    MOV BH, 0
    MOV BL, AL
    MOV ReqE[BX], 1
    MOV Recebeu_comando, 1
    JMP Inicio

DefinirTarget:
    MOV Recebeu_comando, 0
    MOV BX, 7
    CALL DefinirTargetLoopE
    MOV BX, Target
    MOV AX, [BX]
    CMP AX, 0
    JZ DefinirTargetLoopI
    MOV BX, 7
    JMP RotinaPrincipal

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
    JMP RotinaPrincipal

GoToTarget:
    MOV BX, Target
    MOV AL, [BX]
    MOV BX, Sensor_passou_andar
    MOV AH, [BX]
    CMP AH, AL
    JZ ChegouTarget
    JS SubirAndar
    JNS DescerAndar

ChegouTarget:
    MOV BX, Target
    MOV AL, [BX]
    DEC AL
    MOV BH, 0
    MOV BL, AL
    MOV ReqE[BX], 0
    MOV ReqI[BX], 0
    MOV Target, 0
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

PrintMsg:   ;Usando a interrupcao para printar uma cadeia de caracteres
    MOV  AH, 09h 
    INT  21h
    RET

PararExecucao:
    NOP
    RET

ReqE: DB 0, 0, 0, 0, 0, 0, 0, 0 ;Implementar
ReqI: DB 0, 0, 0, 0, 0, 0, 0, 0 ;Implementar
Contadora: DB 0 ;Implementar
Elevador_na_Base: DB 0
Elevador_no_Topo: DB 0
Porta_Aberta: DB 0 ;Implementar
Sensos_preseca: DB 0 ;Implementar
Sensor_passou_andar: DB 1
Recebeu_comando: DB 0
Target: DB 0

SUBIU: DB  "Move para cima $" 
DESCEU: DB  "Move para baixo $"
ABREPORTA: DB  "Abre Porta $"
FECHAPORTA: DB  "Fecha Porta $"