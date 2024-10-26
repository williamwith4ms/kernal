[BITS 16]
[ORG 0x7C00]

; prints hello world then hangs

; Main
MOV DI, helloWorld
CALL printStr
JMP $

; Functions
printChar:
    MOV AH, 0x0E ; teletype output
    MOV BH, 0x00 ; page number
    MOV BL, 0x07 ; fore/back ground colour
    INT 0x10     ; BIOS video interrupt
    RET

printStr:
  nxtChar: ; loop to print each character
    MOV AL, [DI]
    INC DI
    OR AL, AL ; check for null
    JZ exitFn 
    CALL printChar
    JMP nxtChar
  exitFn:
    RET

; Data
helloWorld db 'Hello World!', 0

; Boot Signature
TIMES 510 - ($ - $$) db 0
DW 0xAA55
