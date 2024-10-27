[BITS 16]
org 0x7C00

MOV DI, Loading1
CALL printStr

; Disable interrupts
;CLI

; load segment registers
XOR AX, ax
MOV DS, AX
MOV ES, AX
MOV FS, AX
MOV GS, AX

; set stack pointer
MOV SS, AX
MOV SP, 0x7BFF

; print loading stage 2
;MOV DI, Loading2
;CALL printStr

; Enable interrupts
;STI

; reset disk controller
;MOV AH, 0x00
;MOV DL, 0x00
;INT 0x13

; load stage 1 to memory
MOV AX, 0x7E00
MOV ES, AX
MOV BX, 0x0000
MOV AH, 0x02
MOV AL, 0x01
MOV CH, 0x00
MOV CL, 0x01
MOV DH, 0x00
MOV DL, 0x00

INT 0x13
JC error

CALL dumpMemory

MOV DI, Loading2
CALL printStr
; jump to stage 1
JMP 0x0000:0x7E00

MOV DI, JumpError ; if we get here, something went wrong
CALL printStr 

; Functions
error:
  ; if something goes wrong, hang
  MOV DI, ErrorMessage
  CALL printStr
  CLI
  HLT


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

dumpMemory:
  MOV SI, 0x7E00
  MOV CX, 512
Loop:
  MOV AL, [SI]
  CALL printHex
  INC SI
  LOOP Loop
  RET

printHex:
  PUSH AX
  MOV AH, AL
  SHR AH, 4
  CALL printHexDigit
  MOV AH, AL
  AND AH, 0x0F
  CALL printHexDigit
  POP AX
  RET

printHexDigit:
  ADD AL, '0'
  CMP AL, '9'
  JBE printHexDigitDone
  ADD AL, 7
printHexDigitDone:
  CALL printChar
  RET


; Data
Loading1 db 'Initializing system',0x0A,0x0D, 0
Loading2 db 'Loading stage 1', 0x0A,0x0D, 0
ErrorMessage db 'Error loading stage 1', 0x0A, 0
JumpError db 'Error jumping to stage 1', 0x0A, 0
; Boot Signature
TIMES 510 - ($ - $$) db 0
DW 0xAA55
