[BITS 16]
[ORG 0x7C00]

MOV DI, Loading1
CALL printStr

; Disable interrupts
CLI

; load segmant registers
XOR AX, ax
MOV DS, AX
MOV ES, AX
MOV SS, AX
MOV SP, 0x7C00

MOV DI, Loading2
CALL printStr

; load stage 1 to memory
MOV AX, 2
MOV bx, 0x7E00
MOV ah, 0x02
MOV ch, 0x00
MOV cl, 0x02
MOV dh, 0x00
MOV bx, 0x7e00
MOV al, 0x01
INT 0x13

JC error

; jump to stage 1
JMP 0x0000:0x7E00


; Functions
error:
  ; if something goes wrong, hang
  MOV di, ERROR
  call printStr
  cli
  hlt


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
Loading1 db 'Initializing system',0x0A,0x0D, 0
Loading2 db 'Loading stage 1', 0x0A,0x0D, 0
ERROR db 'Error loading kernel', 0x0A, 0

; Boot Signature
TIMES 510 - ($ - $$) db 0
DW 0xAA55
