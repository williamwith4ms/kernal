[BITS 16]
ORG 0x8000

; Debug message
MOV DI, debug_start
CALL printStr

printChar:
  MOV AH, 0x0E 
  MOV BH, 0x00 
  MOV BL, 0x07 
  INT 0x10     
  RET

printStr:
  nxtChar: 
    MOV AL, [DI]
    INC DI
    OR AL, AL 
    JZ exitFn 
    CALL printChar
    JMP nxtChar
  exitFn:
    RET

; Data
debug_start db 'Loaded stage 1', 0

; boot signature
TIMES 510-($-$$) DB 0
DW 0xAA55
