[BITS 16]
ORG 0x8000


;section .text
MOV DI, message1
CALL printStr

; Print the message "Loaded stage 1"

; Set stack pointer
MOV AX, 0x7C00
MOV SS, AX
MOV SP, 0x7C00



; Query BIOS for size of lower memory
MOV AX, 0x88
INT 0x15

; Query BIOS for size of upper memory
MOV AX, 0xE801
INT 0x15

; load kernel to memory
CALL loadKernel

MOV DI, kernelLoadedMessage
CALL printStr

; Enable A20 line
MOV AL, 0xAD             ; Disable keyboard interrupts
OUT 0x64, AL             ; Send command to keyboard controller

MOV AL, 0xD0             ; Read status register
OUT 0x64, AL             ; Send command
IN AL, 0x60              ; Read status register
OR AL, 0x2               ; Set bit 1 (A20 line)
OUT 0x60, AL             ; Write to status register

; Check if A20 line is enabled
MOV AL, 0xD0             ; Read status register
OUT 0x64, AL             ; Send command
IN AL, 0x60              ; Read status register
AND AL, 0x2              ; Check if bit 1 is set
JZ A20Fail               ; If not, jump to A20Fail
MOV DI, A20Success
CALL printStr

; Disable interrupts
CLI

; Load Global Descriptor Table
LGDT [GDTDescriptor]
MOV DI, GDTMessage
CALL printStr

; Switch to protected mode
MOV EAX, CR0
OR EAX, 0x1
MOV CR0, EAX

JMP 0x08:protectedModeStart


; messages
message1 db 'Loaded stage 1', 0x0A, 0x0D, 0
readError db 'Error reading kernel', 0x0A, 0x0D, 0
A20Success db 'A20 line enabled', 0x0A, 0x0D, 0
A20FailMessage db 'A20 line failed', 0x0A, 0x0D, 0
GDTMessage db 'GDT loaded', 0x0A, 0x0D, 0
ProtectedModeMessage db 'Switched to protected mode', 0x0A, 0x0D, 0
kernelLoadedMessage db 'Kernel loaded', 0x0A, 0x0D, 0
; functions

protectedModeStart:
  mov ax, 0x10
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  hlt

loadKernel:
  ; Load kernel to memory
  MOV BX, 0x1000
  MOV CX, 4
  MOV AH, 0x02
  MOV AL, 16
  MOV CH, 0x00
  MOV CL, 0x03
  MOV DH, 0x00
  INT 0x13
  JC ReadError

A20Fail:
  MOV DI, A20FailMessage
  CALL printStr
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

ReadError:
  ; If something goes wrong, hang
  MOV DI, readError
  CALL printStr
  MOV AL, AH
  CALL printHex
  CLI
  HLT

printHex:
  PUSH AX
  MOV CL, 4

  MOV BL, AL
  SHR BL, CL
  CALL printHexDigit
  MOV BL, AL
  AND BL, 0x0F
  CALL printHexDigit
  POP AX
  RET
printHexDigit:
  ADD AL, '0'
  CMP AL, '9'
  JBE printHexDigitDone
  ADD AL, 7
printHexDigitDone:
  MOV AL,BL
  CALL printChar
  RET


;section .data
GTD:
  dq 0x0000000000000000           ; Limit for GDT
  dq 0x00CF9A000000FFFF           ; Code segment descriptor
  dq 0x00CF92000000FFFF           ; Data segment descriptor

GDTDescriptor:
  dw GTD - GTD - 1      ; Size of the GDT
  dd GTD                ; Pointer to the GDT

TIMES 510 - ($ - $$) db 0 ; dont ask why 330 
DW 0xAA55
