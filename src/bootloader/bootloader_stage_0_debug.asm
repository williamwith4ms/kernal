[BITS 16]
[ORG 0x7C00]

; barebones only needed to get stage 1 in memory

xor ax, ax
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov sp, 0x7C00

mov di, debug_start
call printStr

;load stage 1 to memory
mov ax, 0x0000
mov es, ax
mov bx, 0x8000
mov ah, 0x02
mov al, 0x01
mov ch, 0x00
mov cl, 0x01
mov dh, 0x00
mov dl, 0x00
int 0x13

jc diskError

jmp 0x0000:0x8000

printChar:
    MOV AH, 0x0E 
    MOV BH, 0x00 
    MOV BL, 0x07 
    INT 0x10     
    RET

diskError:
  MOV DI, diskErrorMessage
  CALL printStr
  HLT

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

debug_start db 'Loaded stage 0', 0
diskErrorMessage db 'Error loading stage 1', 0

; boot signature
times 510-($-$$) db 0
dw 0xAA55
