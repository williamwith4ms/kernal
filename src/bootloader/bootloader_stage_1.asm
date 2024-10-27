[BITS 16]
ORG 0x7E00


;section .text
MOV DI, message1
CALL printStr

; Print the message "Loaded stage 1"

; Set stack pointer
;MOV AX, 0x7C00
;MOV SS, AX
;MOV SP, 0x7C00

; Query BIOS for size of lower memory
;MOV AX, 0x88
;INT 0x15

; Query BIOS for size of upper memory
;MOV AX, 0xE801
;INT 0x15

; Read kernel sectors to lower memory
;MOV AH, 0x02
;MOV AL, 0x01
;MOV CH, 0x00
;MOV CL, 0x02
;MOV DH, 0x00
;MOV DL, 0x80
;MOV BX, 0x7E00
;INT 0x13
;JC ReadError

; Enable A20 line
;MOV AL, 0xAD             ; Disable keyboard interrupts
;OUT 0x64, AL             ; Send command to keyboard controller
;MOV AL, 0xD0             ; Read status register
;OUT 0x64, AL             ; Send command
;IN AL, 0x60              ; Read status register
;OR AL, 0x2               ; Set bit 1 (A20 line)
;OUT 0x60, AL             ; Write to status register

; Disable interrupts
;CLI

; Load Global Descriptor Table
;LGDT [GDTDescriptor]

; Switch to protected mode
;MOV EAX, CR0
;OR EAX, 0x1
;MOV CR0, EAX

;JMP 0x08:protectedModeStart


; messages
message1 db 'Loaded stage 1', 0
ERROR db 'Error in stage 1', 0


; functions
;protectedModeStart:
;  MOV AX, 0x10
;  MOV DS, AX
;  MOV ES, AX
;  MOV FS, AX
;  MOV GS, AX
;  MOV SS, AX
;
;  ; Jump to kernel
;  MOV EAX, 0x00100000  ; Kernel is located at 1MB
;  JMP EAX
;
;code_segment:
;  dw 0xFFFF            ; Limit (0-15 bits)
;  dw 0x0000            ; Base (0-15 bits)
;  db 0x9A              ; Type and Attributes (Code Segment, Executable, Readable, Privilege Level 0)
;  db 0xCF              ; Type and Attributes (Segment present, 32-bit segment, Granularity)
;  dw 0x0000            ; Base (16-23 bits)
;
;data_segment:
;  dw 0xFFFF            ; Limit (0-15 bits)
;  dw 0x0000            ; Base (0-15 bits)
;  db 0x92              ; Type and Attributes (Data Segment, Writable, Privilege Level 0)
;  db 0xCF              ; Type and Attributes (Segment present, 32-bit segment, Granularity)
;  dw 0x0000            ; Base (16-23 bits)

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

;ReadError:
  ; If something goes wrong, hang
;  MOV DI, ERROR
;  CALL printStr
;  CLI

;section .data
;GTDstart:
;  dq 0x0000000000000000           ; Limit for GDT
;  dq 0x00CF9A000000FFFF           ; Code segment descriptor
;  dq 0x00CF92000000FFFF           ; Data segment descriptor
;GTDend:
;
;GDTDescriptor:
;  dw GTDend - GTDstart - 1      ; Size of the GDT:W
;  dd GTDstart                   ; Pointer to the GDT
;
TIMES 510 - ($ - $$) db 0 ; dont ask why 330 
DW 0xAA55
