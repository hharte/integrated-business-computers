; IBC/Integrated Business Computers
; IBC DIAGNOSTICS - DISK SLAVE V4.0
;
; Partial disassembly of IBC_DMP014_REV_U.bin
; The PROM is a 2764 (8K*8) EPROM.
;
; Assemble with the zmac assembler: http://48k.ca/zmac.html
;
; Firmware for the IBC ST-506 disk slave.
;
; Looks like per-HDD data is stored at 2C00h (64-bytes per drive.)
;

; I/O Ports (OUT)
; 00h
; 04H
; 08H
; 10H
; 14H
; 1CH
; 20H
; 24H

; IN/OUT
; 2EH
; 2FH   Tape controller
;
; IN
; 0CH
; 0DH
; 18H
; 28H
; 2CH

DATABUF EQU     2000H           ; Sector Data Buffer

; Disk drive parameters:
L2C00   EQU     2C00H
L2C40   EQU     2C40H
L2C80   EQU     2C80H
L2CC0   EQU     2CC0H

; Reset values of drive parameters:
; 2C00  000000FF00000000000000FFFFFF0F20
; 2C10  0320000000010EFC160000FF10FD0EFE
; 2C20  DFEB0EFD100509FF00FF09FF0EFE09FF
; 2C30  0EFE09FF00FF09FE14FF0EFE09FF00FF

; *DM2C00
; *2C00  000000FF00000000000000FFFFFF0464  ...............d
; *2C10  022000000001FFFFFF0000FFFFFFFFFF  . ..............
; *2C20  FFFFFFFDFFFFFFF5FFF5FFF1FFFBFEFF  ................
; *2C30  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  ................
; *2C40  FFFFFFFF00FFFFFFFFFFFFFFFFFF0464  ...............d
; *2C50  022000000001FFFFFFFFFFFFFFFFFFFF  . ..............
; *2C60  FFF5FFF97FFAFFFFFFFFFFFFFFFFFFFF  ..............
; *2C70  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  ................
; *2C80  FFFFFFFF00FFFFFFFFFFFFFFFFFF0464  ...............d
; *2C90  022000000001FFFFFFFFFFFFFFFFFFFF  . ..............
; *2CA0  5FF6FFF6FFFDFFFFFFFFFFFFFFFFFFFF  _...............
; *2CB0  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  ................
; *2CC0  FFFFFFFFFFFFFFFFFFFFFFFFFFFF0264  ...............d
; *2CD0  022090010001FFFFFFFF00FFFFFFFFFF  . ..............
; *2CE0  FFFCFFFFFFFFFFF5FEFDFFFFFFFFFFFF  ................
; *2CF0  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  ................
; 
; >INITDISK A (FORMAT
;
; INITDISK will erase all files on drive A(3)
; Do you wish to continue (Y/N)? Y
;
; Enter disk Label: ST225
;
; Number of directory entries = 944
; Increment between adjacent sectors = 1
; Offset between adjacent tracks = 0
; Number of surfaces = 4
; Number of tracks per surface = 508
; Number of sectors per track = 32
; 
; Is above information correct (Y/N)? Y
; 
; Input Flaw Map for this disk unit. (Press return when done.)
; TRACK,HEAD  (in hex)



; Offsets within the disk drive parameters:
DCTRKLO EQU     01H             ; Current Track Low Byte
DCTRKHI EQU     02H             ; Current Track High Byte
DHEADS  EQU     0EH             ; Number of heads
DMTRKLO EQU     0FH             ; Maximum Track Low Byte
DMTRKHI EQU     10H             ; Maximum Track High Byte
DSECPT  EQU     11H             ; Sectors per track
DWPCLO  EQU     12H             ; Track Low Byte
DWPCHI  EQU     13H             ; Track High Byte
DONLINE EQU     1AH             ; FFh = Offline, other value = online.

; Controller State
L2D00   EQU     2D00H           ; ?
L2D01   EQU     2D01H           ; Active drive (parameter table pointed to by IY)
L2D18   EQU     2D18H           ; ?
L2D21   EQU     2D21H           ; Selected drive (ie, by US command.)
L2D25   EQU     2D25H           ; Head parameter.
L2DF6   EQU     2DF6H           ; ?

        ORG     0

RESET:  XOR     A
        LD      (2D3FH),A
l0004:  LD      SP,3000H
        IM      1
        EI      
        LD      A,02H
        OUT     (14H),A
        LD      A,08H
        OUT     (1CH),A
        LD      A,01H
        LD      (L2D18),A
        IN      A,(28H)
        BIT     7,A
        JP      L03F2
     
        ORG     0038H
RST38   LD      A,08H
        OUT     (1CH),A
        EX      (SP),HL
        INC     HL
        INC     HL
        EX      (SP),HL
        RETI    

        NOP     

l0043:  LD      (IY+04H),00H
l0047:  CALL    L06B2
        INC     (IY+04H)
        LD      A,(IY+04H)
        CP      (IY+DHEADS)
        JR      Z,L0057                 ; (+02h)
        JR      L0047                   ; (-10h)
l0057:  DEC     A
        LD      (IY+0DH),A
        RET     

WRSECT: PUSH    BC
        LD      (IY+0BH),B
        CALL    L0604
        JR      C,L0079                 ; (+14h)
        CALL    L0194
        JR      C,L0079                 ; (+0fh)
        POP     BC
        PUSH    BC
        LD      A,C
        LD      HL,2011H
        LD      B,00H
l0072:  LD      (HL),A
        INC     HL
        DJNZ    L0072                   ; (-04h)
        CALL    L0C26
l0079:  POP     BC
        RET     

        LD      (IY+0BH),B
        CALL    L0194
        JR      C,L0086                 ; (+03h)
        CALL    L0C26
l0086:  RET     

l0087:  PUSH    BC
        LD      (IY+0BH),B
        CALL    L0604
        JR      C,L00A3                 ; (+13h)
        CALL    L0194
        JR      C,L00A3                 ; (+0eh)
        LD      HL,2011H
        LD      BC,0000
l009b:  LD      (HL),C
        INC     HL
        INC     C
        DJNZ    L009B                   ; (-05h)
        CALL    L0C26
l00a3:  POP     BC
        RET     

l00a5:  LD      (IY+04H),00H
        CALL    L06B2
        CALL    L02AF
        LD      B,(IY+DMTRKHI)
        LD      C,(IY+DMTRKLO)
        LD      A,0CH
l00b7:  PUSH    BC
        CALL    L0AB6
        POP     BC
        DEC     BC
        LD      A,B
        OR      C
        JR      NZ,L00B7                ; (-0ah)
l00c1:  IN      A,(18H)
        BIT     2,A
        JR      NZ,L00C1                ; (-06h)
        CALL    L02AF
        RET     

RDSECT: PUSH    BC                      ; L 00CB
        LD      HL,2DA2H
        LD      (2DA0H),HL
        LD      (IY+0BH),A
        LD      (2D24H),A
        LD      A,01H
        LD      (2D26H),A
        CALL    L0604
        JR      C,L00F5                 ; (+13h)
        CALL    L0194
        JR      C,L00F5                 ; (+0eh)
        CALL    L0CA3
        JR      C,L00F5                 ; (+09h)
        LD      HL,2007H
        LD      (2D92H),HL
        CALL    L0DF0
l00f5:  POP     BC
        RET     

l00f7:  PUSH    AF
        XOR     A
        LD      (L2DF6),A
        LD      (L2D25),A
        POP     AF
        CALL    L0604
        CALL    L0373
        CALL    L02AF
        LD      HL,L2C00
        LD      (DATABUF),HL
        LD      B,01H
        LD      C,00H
        LD      HL,0000
        LD      DE,0001H
        CALL    L09E6
        RET     

l011d:  XOR     A
        LD      (L2D25),A
        CALL    L0604
        CALL    L02AF
        CALL    L0373
        LD      B,(IY+DSECPT)
l012d:  OUT     (00H),A
        LD      A,05H
        OUT     (1CH),A
        LD      A,08H
        OUT     (1CH),A
        DJNZ    L012D                   ; (-0ch)
        RET     

l013a:  CALL    L0604
        JR      C,L0147                 ; (+08h)
        CALL    L0194
        JR      C,L0147                 ; (+03h)
        CALL    L0D3B
l0147:  RET     

l0148:  PUSH    BC
        LD      B,02H
l014b:  LD      C,0FEH
        CALL    L0D3B
        LD      A,(HL)
        CP      0A1H
        JR      NZ,L0162                ; (+0dh)
        INC     HL
        LD      A,(HL)
        CP      0F8H
        JR      Z,L014B                 ; (-10h)
        CP      C
        JR      NZ,L0162                ; (+04h)
        OR      A
        INC     HL
        JR      L0167                   ; (+05h)
l0162:  DJNZ    L014B                   ; (-19h)
        LD      A,03H
        SCF     
l0167:  POP     BC
        RET     

; Format all tracks with a given head (in 2D25H )
FMTHEAD:
        LD      A,01H                   ; l 0169
        LD      (L2DF6),A
        LD      A,(L2D25)
        CP      (IY+DHEADS)             ; Make sure head is valid.
        JR      NC,L0192                ; (+1ch)
        PUSH    AF
        CALL    L0604
        CALL    L0373
        CALL    L0284
        LD      HL,0000
        LD      E,(IY+DMTRKLO)
        LD      D,(IY+DMTRKHI)
        POP     AF
        LD      C,A
        LD      B,01H
        CALL    L09E6
        XOR     A
        RET     

l0192:  SCF     
        RET     

l0194:  LD      A,(IY+08H)
        OR      A
        INC     A
        CALL    Z,L02AF
        JP      C,L0233
        LD      E,(IY+07H)
        LD      D,(IY+08H)
        LD      L,(IY+09H)
        LD      H,(IY+0AH)
        OR      A
        SBC     HL,DE
        LD      A,H
        OR      L
        JR      Z,L01C1                 ; (+0fh)
        LD      L,(IY+09H)
        LD      H,(IY+0AH)
        LD      (IY+05H),L
        LD      (IY+06H),H
        CALL    L0234
l01c1:  CALL    L0322
        JR      NC,L0227                ; (+61h)
        LD      E,A
        LD      A,(HL)
        CP      0AAH
        LD      A,E
        SCF     
        JP      NZ,L0233
        INC     HL
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        PUSH    DE
        LD      A,D
        RRCA    
        RRCA    
        RRCA    
        RRCA    
        AND     0FH
        LD      (IY+04H),A
        LD      A,(IY+05H)
        LD      (IY+DCTRKLO),A
        LD      A,(IY+06H)
        LD      (IY+DCTRKHI),A
        LD      A,(IY+0CH)
        LD      (IY+00H),A
        CALL    L06B2
        JP      C,L0233
        POP     DE
        LD      A,D
        AND     0FH
        LD      (IY+05H),E
        LD      (IY+06H),A
        CALL    L0234
        CALL    L0322
        LD      (IY+19H),01H
        JR      NC,L0227                ; (+1bh)
        XOR     A
        LD      (IY+19H),A
        DEC     A
        LD      (IY+07H),A
        LD      (IY+08H),A
        LD      (IY+DCTRKLO),A
        LD      (IY+DCTRKHI),A
        LD      (IY+0DH),A
        LD      (IY+00H),A
        LD      A,08H
        JR      L0233                   ; (+0ch)
l0227:  LD      L,(IY+09H)
        LD      H,(IY+0AH)
        LD      (IY+07H),L
        LD      (IY+08H),H
l0233:  RET     

l0234:  CALL    L0373
        LD      E,(IY+DCTRKLO)
        LD      D,(IY+DCTRKHI)
        LD      L,(IY+05H)
        LD      H,(IY+06H)
        OR      A
        SBC     HL,DE
        LD      A,0CH
        JR      NC,L0256                ; (+0ch)
        LD      L,(IY+05H)
        LD      H,(IY+06H)
        EX      DE,HL
        OR      A
        SBC     HL,DE
        LD      A,04H
l0256:  LD      D,A
        LD      A,H
        OR      L
        JR      Z,L0268                 ; (+0dh)
        LD      A,D
        CALL    L026F
        DEC     HL
        JR      L0256                   ; (-0ch)
l0262:  IN      A,(18H)
        BIT     2,A
        JR      Z,L0262                 ; (-06h)
l0268:  IN      A,(18H)
        BIT     2,A
        JR      NZ,L0268                ; (-06h)
        RET     

l026f:  PUSH    AF
        AND     08H
        OUT     (14H),A
        POP     AF
        OUT     (14H),A
        PUSH    BC
        PUSH    AF
        RES     2,A
        OUT     (14H),A
        LD      B,02H
l027f:  DJNZ    L027F                   ; (-02h)
        POP     AF
        POP     BC
        RET     

l0284:  IN      A,(18H)
        BIT     1,A
        JR      Z,L029C                 ; (+12h)
l028a:  CALL    L0373
        LD      A,04H
        CALL    L026F
l0292:  IN      A,(18H)
        BIT     2,A
        JR      NZ,L0292                ; (-06h)
        BIT     1,A
        JR      NZ,L028A                ; (-12h)
l029c:  LD      DE,0000
        LD      (IY+DCTRKLO),E
        LD      (IY+DCTRKHI),D
        LD      (IY+08H),D
        LD      (IY+07H),E
        LD      (IY+19H),D
        RET     

l02af:  LD      B,02H
l02b1:  PUSH    BC
        CALL    L0148
        POP     BC
        JR      NC,L02C7                ; (+0fh)
        LD      A,(HL)
        CP      0AAH
        LD      A,08H
        SCF     
        JR      NZ,L0321                ; (+61h)
        LD      A,0CH
        CALL    L026F
        JR      L02B1                   ; (-16h)
l02c7:  LD      C,(HL)
        INC     HL
        LD      A,(HL)
        AND     0FH
        LD      (IY+08H),A
        LD      (IY+DCTRKHI),A
        LD      (IY+07H),C
        LD      (IY+DCTRKLO),C
        LD      E,(IY+09H)
        LD      D,(IY+0AH)
        PUSH    DE
        LD      E,(IY+05H)
        LD      D,(IY+06H)
        PUSH    DE
        XOR     A
        LD      (IY+09H),A
        LD      (IY+0AH),A
        LD      (IY+06H),A
        LD      (IY+05H),A
        CALL    L0234
        POP     DE
        LD      (IY+06H),D
        LD      (IY+05H),E
        POP     DE
        LD      (IY+0AH),D
        LD      (IY+09H),E
        IN      A,(18H)
        BIT     1,A
        JR      Z,L0311                 ; (+07h)
        DJNZ    L02B1                   ; (-5bh)
        LD      A,03H
        SCF     
        JR      L0321                   ; (+10h)
l0311:  XOR     A
        LD      (IY+07H),A
        LD      (IY+08H),A
        LD      (IY+DCTRKHI),A
        LD      (IY+DCTRKLO),A
        LD      (IY+19H),A
l0321:  RET     

l0322:  CALL    L0373
        CALL    L0148
        JR      C,L0372                 ; (+48h)
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        LD      (IY+DCTRKLO),E
        LD      A,D
        AND     0FH
        LD      (IY+DCTRKHI),A
        LD      L,(IY+05H)
        LD      H,(IY+06H)
        PUSH    DE
        LD      D,A
        OR      A
        SBC     HL,DE
        POP     DE
        LD      A,H
l0343:  OR      L
        JR      Z,L035A                 ; (+14h)
        LD      A,0FFH
        LD      (IY+07H),A
        LD      (IY+08H),A
        LD      (IY+DCTRKLO),A
        LD      (IY+DCTRKHI),A
        LD      A,0CH
        SCF     
        JP      L0372
l035a:  LD      A,D
        OR      A
        RRCA    
        RRCA    
        RRCA    
        RRCA    
        AND     0FH
        CP      (IY+00H)
        JR      Z,L0372                 ; (+0bh)
        LD      A,0FFH
        LD      (IY+00H),A
        LD      (IY+0DH),A
        LD      A,03H
        SCF     
l0372:  RET     

l0373:  IN      A,(18H)
        BIT     4,A
        JR      NZ,L0373                ; (-06h)
        RET     

;
L037A:  LD      IY,L2C00
        LD      DE,2C0EH
        LD      HL,L038E
        LD      BC,0008H
        LDIR                            ; Copy 8 bytes from 038EH to 2C0EH
        XOR     A
        LD      (L2D01),A
        RET     
; Hard Disk Drive Parameters
L038E:  DB      006H, 032H, 001H, 020H, 0FEH, 00H, 00H, 01H             ; 0 = 0132H = 306
        DB      006H, 080H, 002H, 020H, 0FEH, 00H, 00H, 01H             ; 1 = 0280H = 640
        DB      004H, 0E0H, 001H, 020H, 000H, 00H, 00H, 01H             ; 2 = 01e0H = 480
        DB      008H, 000H, 002H, 020H, 0FEH, 00H, 00H, 01H             ; 3 = 0200H = 512
        DB      006H, 040H, 001H, 020H, 080H, 00H, 00H, 01H             ; 4 = 0140H = 320
        DB      008H, 040H, 001H, 020H, 080H, 00H, 00H, 01H             ; 5 = 0140H = 320
        DB      007H, 0F2H, 002H, 020H, 080H, 01H, 00H, 01H             ; 6 = 02F2H = 754
        DB      00BH, 0F2H, 002H, 020H, 080H, 01H, 00H, 01H             ; 7 = 02F2H = 754

L03CE:  DB      002H, 064H, 002H, 020H, 090H, 01H, 00H, 01H             ; 8 = 0264H = 612
        DB      002H, 032H, 001H, 020H, 032H, 01H, 00H, 01H             ; 9 = 0132H = 306
        DB      002H, 064H, 002H, 020H, 000H, 00H, 00H, 01H             ; A = 0264H = 612
        DB      007H, 032H, 001H, 020H, 032H, 01H, 00H, 01H             ; B = 0132H = 306

        DB      04EH, 000H, 0A1H, 0FEH

L03F2:  CALL    L04D6                   ; Initialize data structures
l03f5:  LD      HL,2D20H
        CALL    L05B6                   ; Wait for TF command from Host?
        LD      A,30H
        OUT     (08H),A                 ; Set Status to 30H?
        CALL    L05C4
        LD      A,(2D20H)
        CP      02H                     ; Write sector?
        JR      NZ,L043E                ; (+35h)
        CALL    L069B
        LD      A,(2D26H)
        LD      (2D94H),A
        LD      B,A
        LD      DE,0100H
        LD      HL,0000
l0419:  ADD     HL,DE
        DJNZ    L0419                   ; (-03h)
        EX      DE,HL
        LD      HL,0A00H
        OR      A
        SBC     HL,DE
        JR      NC,L042A                ; (+05h)
        LD      A,05H
        SCF     
        JR      L0472                   ; (+48h)
l042a:  EX      DE,HL
        PUSH    HL
        LD      DE,DATABUF
        ADD     HL,DE
        DEC     HL
        EX      DE,HL
        LD      HL,2200H
        LD      (2D90H),HL
        POP     BC
        ADD     HL,BC
        DEC     HL
        EX      DE,HL
        LDDR    
l043e:  LD      HL,2D08H
        LD      A,(L2D21)
        AND     03H
        LD      E,A
        LD      D,00H
        ADD     HL,DE
        LD      A,(HL)
        LD      (2D05H),A
        LD      A,(2D20H)
        CP      1CH
        JR      C,L045A                 ; (+05h)
        LD      A,05H
        SCF     
        JR      L0472                   ; (+18h)

l045a:  CALL    L048C
        JR      C,L0462                 ; (+03h)
        OR      A
        JR      Z,L0470                 ; (+0eh)

l0462:  LD      B,A
        LD      A,(2D05H)
        DEC     A
        LD      (2D05H),A
        JR      NZ,L045A                ; (-12h)
        LD      A,B
        SCF     
l046e:  JR      L0472                   ; (+02h)

l0470:  LD      A,40H
l0472:  OUT     (08H),A
        LD      A,(2D3FH)
        OR      A
        JP      Z,L03F5
        LD      A,(2D20H)
        CP      02H
        JR      Z,L0487                 ; (+05h)
        CP      01H
        JP      NZ,L03F5

l0487:  OUT     (04H),A
        JP      L03F5

l048c:  LD      A,(2D20H)
        ADD     A,A
        LD      E,A
        LD      D,00H
        LD      HL,049EH
        ADD     HL,DE
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        PUSH    HL
        EX      DE,HL
l049c:  EX      (SP),HL
        RET     

; Controller Command Jump Table
L049E:  DW      RESET           ; 00H - Reset Controller
        DW      L0721           ; 01H - HD Read?
        DW      L0721           ; 02H - HW Write?
        DW      L094D           ; 03H
        DW      L094D           ; 04H
        DW      L0951           ; 05H - Simply returns.
        DW      L08A9           ; 06H
        DW      L08EC           ; 07H
        DW      L085E           ; 08H - Format?
        DW      L085E           ; 09H
        DW      L18FF           ; 0AH
        DW      L0600           ; 0BH - Access FIFO?
        DW      HMCMD           ; 0CH - Home
        DW      L097E           ; 0DH
        DW      L0989           ; 0EH
        DW      L090A           ; 0FH
        DW      L0F72           ; 10H - Read Parameters?
        DW      GLCMD           ; 11H - GLCMD
        DW      L12F1           ; 12H
        DW      L1316           ; 13H
        DW      L1804           ; 14H
        DW      L1831           ; 15H
        DW      RWCMD           ; 16H - Rewind
        DW      TMCMD           ; 17H = Mount
        DW      L177A           ; 18H
        DW      L18F5           ; 19H
        DW      SVCMD           ; 1AH - SVCMD
        DW      L0977           ; 1BH

; INIT data structures
L04D6:  LD      A,10H
        OUT     (08H),A
        OUT     (00H),A
        LD      DE,L2D00
        LD      HL,L09C1
        LD      BC,11
        LDIR                            ; Copy 11 bytes from 09C1H to 2D00
        LD      B,04H
        LD      C,00H
l04eb:  PUSH    BC
        LD      HL,L09B9
        LD      E,C
        LD      D,00H
        ADD     HL,DE
        ADD     HL,DE
        LD      E,(HL)
        INC     HL
        LD      D,(HL)                  ; Point DE to 2C00, 2c40, 2c80, 2cc0 depending on drive selected.
        LD      HL,L09CC
l04fa:  LD      BC,14
        LDIR                            ; Copy 14 bytes from 09CC to 2C00, copy same 14 bytes to 2C40, 2C80, 2CC0
        POP     BC
        INC     C
        DJNZ    L04EB                   ; (-18h)
        LD      B,03H
        LD      C,00H
l0507:  LD      HL,L09B9
        LD      E,C
        LD      D,00H
        ADD     HL,DE
        ADD     HL,DE
        LD      E,(HL)
        INC     HL
        LD      D,(HL)                  ; Point DE to 2C00, 2c40, 2c80, 2cc0 depending on drive selected.
        LD      HL,000EH
        ADD     HL,DE
        LD      DE,L09DE                ; Default HD parameters (heads, tracks, sectors/track, precomp)
        EX      DE,HL
        PUSH    BC
        LD      BC,0008H
        LDIR                            ; Copy 8 bytes from 09DE to 2C0E. 2C4E, 2C8E, 2CCE
        POP     BC
        INC     C
        DJNZ    L0507                   ; (-1dh)
        LD      DE,2CCEH
        LD      HL,L03CE
        LD      BC,0008H
        LDIR                            ; Copy 8 bytes from 03CE to 2CCE

; Initialize each of the four hard drives.
        LD      B,03H                   ; Loop four times.
HDINITLP:
        PUSH    BC
        DEC     B
        LD      A,B
        LD      (L2D01),A
        LD      HL,L09B9
        LD      E,A
        LD      D,00H
        ADD     HL,DE
        ADD     HL,DE
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        PUSH    DE
        POP     IY
        LD      (IY+04H),00H
l0549:  LD      (IY+DONLINE),00H        ; Assume drive is online.
        LD      HL,L09DA
        LD      E,B
        LD      D,00H
        ADD     HL,DE
        LD      A,(HL)
        LD      B,A
        CALL    DCHKONL                 ; Check if HDD is online
        JR      C,L056D                 ; ... it's not.
        XOR     A
        LD      (IY+09H),A
        LD      (IY+0AH),A
        LD      (IY+05H),A
        LD      (IY+06H),A
        CALL    L0284                   ; starts doing a lot of I/O and gets stuck here.
        JR      L0571                   ; (+04h)

l056d:  LD      (IY+DONLINE),0FFH
l0571:  POP     BC
        DJNZ    HDINITLP                   ; (-43h)

        LD      HL,L09B9
        LD      DE,0006H
        ADD     HL,DE
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        PUSH    DE
        POP     IY
        LD      (IY+07H),0FFH           ; IY=2CC0
        LD      (IY+08H),0FFH
        LD      (IY+DCTRKLO),0FFH
        LD      (IY+DCTRKHI),0FFH
        LD      (IY+DONLINE),00H
        LD      IY,L2C00
        XOR     A
        LD      (L2D00),A
        LD      HL,0000
        LD      (2D06H),HL
        LD      (2DF3H),HL
        XOR     A
        OUT     (08H),A
        LD      (2DF2H),A
        INC     A
        LD      (L2D18),A
        LD      A,0FFH
        LD      (2D1AH),A
        RET     

l05b6:  LD      C,0CH
l05b8:  IN      A,(C)
        BIT     7,A
        JR      Z,L05B8                 ; (-06h)
        CP      0FFH
        JR      Z,L05B8                 ; (-0ah)
        JR      L05D7                   ; (+13h)
l05c4:  PUSH    HL
        LD      HL,0000
        LD      C,0CH
l05ca:  INC     HL
        LD      A,L
        OR      H
        JP      Z,L0004
        IN      A,(C)
        BIT     7,A
        JR      NZ,L05CA                ; (-0ch)
        POP     HL
l05d7:  LD      A,10H
        OUT     (08H),A
        PUSH    BC
        PUSH    HL
        IN      A,(C)
        RES     7,A
        LD      (HL),A
        LD      B,03H
l05e4:  INC     C
        INC     HL
        IN      A,(C)
        LD      (HL),A
        DJNZ    L05E4                   ; (-07h)
        POP     HL
        POP     BC
        PUSH    BC
        PUSH    HL
l05ef:  IN      A,(C)
        RES     7,A
        CP      (HL)
        JR      Z,L05F9                 ; (+03h)
        LD      (HL),A
        JR      L05EF                   ; (-0ah)
l05f9:  POP     HL
        POP     BC
        INC     HL
        INC     HL
        INC     HL
        INC     HL
        RET     

L0600:  XOR     A
        OUT     (00H),A
        RET     

; Seek?
l0604:  CALL    L069B
        LD      A,(L2D25)
        AND     0FH
        LD      (IY+0CH),A
        CP      (IY+DHEADS)
        JR      C,L061A                 ; (+06h)
        LD      A,05H
        SCF     
        JP      L069A
l061a:  LD      HL,(2D22H)
        LD      (IY+09H),L
        LD      (IY+0AH),H
        LD      A,(IY+19H)
        DEC     A
        JR      Z,L0646                 ; (+1dh)
        LD      A,(IY+0CH)
        LD      (IY+04H),A
        LD      HL,(2D22H)
        LD      (IY+05H),L
        LD      (IY+06H),H
        LD      A,(IY+DCTRKLO)
        LD      (IY+07H),A
        LD      A,(IY+DCTRKHI)
        LD      (IY+08H),A
        JR      L0697                   ; (+51h)
l0646:  LD      HL,(2D22H)
        LD      E,(IY+07H)
        LD      D,(IY+08H)
        OR      A
        SBC     HL,DE
        LD      A,H
        OR      L
        JR      NZ,L0672                ; (+1ch)
        LD      A,(IY+0CH)
        CP      (IY+0DH)
        JR      NZ,L0672                ; (+14h)
        LD      A,(IY+00H)
        LD      (IY+04H),A
        LD      A,(IY+DCTRKLO)
        LD      (IY+05H),A
        LD      A,(IY+DCTRKHI)
        LD      (IY+06H),A
        JR      L0697                   ; (+25h)
l0672:  LD      A,(IY+DCTRKLO)
        LD      (IY+07H),A
        LD      A,(IY+DCTRKHI)
        LD      (IY+08H),A
        LD      A,(IY+00H)
        LD      (IY+0DH),A
        LD      A,(IY+0CH)
        LD      (IY+04H),A
        LD      HL,(2D22H)
        LD      (IY+05H),L
        LD      (IY+06H),H
        XOR     A
        LD      (IY+19H),A
l0697:  CALL    L06B2
l069a:  RET     

; Point IY to currently selected drive parameter table.
l069b:  LD      A,(L2D21)
        AND     03H                     ; Make sure drive is 0-3.
        LD      (L2D01),A               ; Store it as the actively selected drive.
        LD      E,A
        LD      HL,L09B9
        LD      D,00H
        ADD     HL,DE
        ADD     HL,DE
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        PUSH    DE
        POP     IY
        RET     

l06b2:  LD      A,(L2D00)
        LD      B,A
        LD      A,(L2D01)
        CP      B
        JR      NZ,L06C4                ; (+08h)
        LD      A,(IY+04H)
        CP      (IY+00H)
        JR      Z,L06DF                 ; (+1bh)
l06c4:  LD      C,(IY+04H)
        BIT     3,C
        JR      Z,L06CF                 ; (+04h)
        LD      A,C
        XOR     88H
        LD      C,A
l06cf:  LD      HL,L09DA
        LD      A,(L2D01)
        LD      E,A
        LD      D,00H
        ADD     HL,DE
        LD      A,(HL)
        OR      C
        LD      B,A
        CALL    DCHKONL
l06df:  RET     

; Check if HDD is online?
DCHKONL:  LD      A,B
        OUT     (10H),A
        LD      HL,00FFH
l06e6:  IN      A,(18H)
        BIT     5,A
        JR      Z,L0701
        DEC     HL
        LD      A,H
        OR      L
        JR      NZ,L06E6
        LD      A,0FFH
        LD      (L2D00),A
        LD      (IY+00H),A
        LD      (IY+0DH),A
        LD      A,01H
        SCF                             ; Drove is not online.
        JR      L0720                   ; (+1fh)
l0701:  LD      A,(L2D01)
        LD      (L2D00),A
        LD      A,(IY+04H)
        LD      (IY+00H),A
        LD      A,(IY+0CH)
        LD      (IY+0DH),A
        LD      A,B
        LD      B,00H
l0716:  DJNZ    L0716                   ; Delay 256 loops.
        LD      B,A
l0719:  IN      A,(18H)
        BIT     2,A
        JR      NZ,L0719
        XOR     A                       ; Drive is online.
l0720:  RET     

L0721:  CALL    L0604
        JP      C,L0773
        LD      A,(2D20H)
        CP      01H
        JR      Z,L073A                 ; (+0ch)
        LD      A,(2D26H)
        LD      (2D94H),A
        LD      HL,2200H
        LD      (2D90H),HL
l073a:  CALL    L0194
        JR      C,L0773                 ; (+34h)
        LD      HL,(2D22H)
        LD      A,H
        CP      (IY+08H)
        JR      NZ,L077B                ; (+33h)
        LD      A,L
        CP      (IY+07H)
        JR      NZ,L077B                ; (+2dh)
        LD      A,(2D24H)
        CP      (IY+DSECPT)
        JR      NC,L0776                ; (+20h)
        LD      (IY+0BH),A
        LD      B,A
        LD      A,(2D26H)
        DEC     A
        ADD     A,B
        CP      (IY+DSECPT)
        JR      NC,L0776                ; (+12h)
        LD      A,(2D20H)
        CP      01H
        JR      NZ,L0770                ; (+05h)
        CALL    L0780
        JR      L0773                   ; (+03h)
l0770:  CALL    L0809
l0773:  OUT     (00H),A
        RET     

l0776:  LD      A,05H
        SCF     
        JR      L0773                   ; (-08h)
l077b:  LD      A,08H
        SCF     
        JR      L0773                   ; (-0dh)
l0780:  LD      HL,2DA2H
        LD      (2DA0H),HL
        LD      A,(2D26H)
        LD      (2D94H),A
        DEC     A
        JR      NZ,L07AE                ; (+1fh)
        CALL    L0CA3
        JP      C,L0808
        LD      HL,2007H
        LD      (2D92H),HL
        CALL    L0DF0
        JR      C,L0808                 ; (+68h)
        LD      DE,DATABUF
        LD      HL,2007H
        LD      BC,0100H
        LDIR    
        JP      L0808
l07ae:  LD      HL,2200H
        LD      (2D90H),HL
l07b4:  CALL    L0CA3
        JR      C,L0808                 ; (+4fh)
        LD      HL,2007H
        LD      A,(2D1AH)
        OR      A
        JR      NZ,L07CA                ; (+08h)
        LD      BC,(2D1CH)
        OTIR    
        JR      L07DA                   ; (+10h)
l07ca:  LD      DE,(2D90H)
        LD      HL,2007H
        LD      BC,0100H
        LDIR    
        LD      (2D90H),DE
l07da:  INC     (IY+0BH)
        LD      A,(2D94H)
        DEC     A
        LD      (2D94H),A
        JR      NZ,L07B4                ; (-32h)
        LD      A,(2D1AH)
        OR      A
        JR      Z,L0808                 ; (+1ch)
        LD      HL,2200H
        LD      (2D92H),HL
        CALL    L0DF0
        JR      C,L0808                 ; (+11h)
        LD      DE,2200H
        LD      HL,(2D90H)
        OR      A
        SBC     HL,DE
        LD      C,L
        LD      B,H
        LD      HL,DATABUF
        EX      DE,HL
        LDIR    
l0808:  RET     

l0809:  LD      B,05H
l080b:  PUSH    BC
        LD      A,(2D1AH)
        OR      A
        JR      NZ,L0828                ; (+16h)
        LD      A,B
        CP      05H
        JR      Z,L081C                 ; (+05h)
        LD      DE,2111H
        JR      L0833                   ; (+17h)
l081c:  LD      HL,2011H
        LD      BC,(2D1CH)
        INIR    
        EX      DE,HL
        JR      L0833                   ; (+0bh)
l0828:  LD      HL,(2D90H)
        LD      DE,2011H
        LD      BC,0100H
        LDIR    
l0833:  LD      B,08H
        XOR     A
l0836:  LD      (DE),A
        INC     DE
        DJNZ    L0836                   ; (-04h)
        CALL    L0C26
        POP     BC
        JR      NC,L0844                ; (+04h)
        DJNZ    L080B                   ; (-37h)
        JR      L085D                   ; (+19h)
l0844:  LD      A,(2D94H)
        DEC     A
        JR      Z,L085D                 ; (+13h)
        LD      (2D94H),A
        INC     (IY+0BH)
        LD      HL,(2D90H)
        LD      DE,0100H
        ADD     HL,DE
        LD      (2D90H),HL
        JP      L0809
l085d:  RET     

L085E:  XOR     A
        LD      (L2DF6),A
        LD      (L2D18),A
        INC     A
        LD      (2D05H),A
        CALL    L0604
        JR      C,L08A1                 ; (+33h)
        LD      A,(IY+DCTRKHI)
        INC     A
        CALL    Z,L0284
        JR      C,L08A1                 ; (+2ah)
        LD      HL,(2D22H)
        LD      A,H
        OR      L
        CALL    Z,L0284
        LD      HL,(2D22H)
        LD      DE,(2D26H)
        LD      A,(L2D25)
        AND     0FH
        LD      C,A
        LD      A,(2D24H)
        AND     0FH
        LD      B,A
        LD      A,(2D20H)
        CP      08H
        JR      NZ,L089E                ; (+05h)
        CALL    L09E6
        JR      L08A1                   ; (+03h)
l089e:  CALL    L0BE0
l08a1:  PUSH    AF
        LD      A,01H
        LD      (L2D18),A
        POP     AF
        RET     

L08A9:  PUSH    IY
        CALL    L069B
        LD      A,(L2D21)
        RRCA    
        RRCA    
        AND     0FH
        LD      (IY+DHEADS),A
        LD      DE,(2D22H)
        LD      (IY+DMTRKLO),E
        LD      (IY+DMTRKHI),D
        LD      A,(L2D25)
        LD      (IY+16H),A
        LD      A,(2D24H)
        LD      (IY+DSECPT),A
        LD      DE,(2D26H)
        LD      (IY+DWPCLO),E
        LD      (IY+DWPCHI),D
        LD      HL,2D08H
        LD      A,(L2D21)
        AND     03H
        LD      E,A
        LD      D,00H
        ADD     HL,DE
        LD      A,(L2D25)
        LD      (HL),A
        XOR     A
        POP     IY
        RET     

L08EC:  PUSH    IY
        CALL    L069B
        PUSH    IY
        POP     HL
        LD      DE,000EH
        ADD     HL,DE
        LD      DE,DATABUF
        LD      BC,0009H
        LDIR    
        OUT     (00H),A
        XOR     A
        JR      L0907                   ; (+02h)
        LD      A,01H
l0907:  POP     IY
        RET     

L090A:  PUSH    IY
        CALL    L069B
        LD      A,(L2D01)
        CP      03H
        JR      Z,L0947                 ; (+31h)
        LD      HL,(2D22H)
        LD      DE,0080H
        OR      A
        SBC     HL,DE
        JR      Z,L0931                 ; (+10h)
        SBC     HL,DE
        JR      Z,L0937                 ; (+12h)
        SBC     HL,DE
        SBC     HL,DE
        JR      NZ,L0947                ; (+1ch)
        LD      (IY+DSECPT),11H
        JR      L093B                   ; (+0ah)
l0931:  LD      (IY+DSECPT),38H
        JR      L093B                   ; (+04h)
l0937:  LD      (IY+DSECPT),20H
l093b:  LD      HL,(2D22H)
        LD      (IY+14H),L
        LD      (IY+15H),H
        XOR     A
        JR      L094A                   ; (+03h)
l0947:  LD      A,05H
        SCF     
l094a:  POP     IY
        RET     

L094D:  LD      A,05H
        SCF     
        RET     

L0951:  RET

HMCMD:  XOR     A
        LD      (L2D25),A
        LD      B,03H
l0958:  PUSH    BC
        DEC     B
        LD      A,B
        LD      (L2D21),A
        CALL    L0604
        JR      C,L0973                 ; (+10h)
        LD      L,(IY+DMTRKLO)
        LD      H,(IY+DMTRKHI)
        DEC     HL
        LD      (IY+09H),L
        LD      (IY+0AH),H
        CALL    L0194
l0973:  POP     BC
        DJNZ    L0958                   ; (-1eh)
        RET     

L0977:  LD      A,01H
        LD      (2D3FH),A
        XOR     A
        RET     

L097E:  LD      A,(L2D21)
        LD      (L2D18),A
        XOR     A
        LD      (2D06H),A
        RET     

L0989:  LD      A,(2D06H)
        SCF     
        RET     

SVCMD:  LD      A,03H                   ; L 098E
        LD      (L2D00),A
        LD      A,40H
        OUT     (10H),A
        LD      B,80H
l0999:  DJNZ    L0999                   ; Delay (128 loops)
l099b:  IN      A,(18H)
        BIT     5,A
        JR      NZ,L099B                ; (-06h)
        LD      B,00H
l09a3:  DJNZ    L09A3                   ; Delay (256 loops)
        LD      A,42H
        OUT     (10H),A
        LD      HL,8000H
l09ac:  DJNZ    L09AC                   ; Delay (256 loops)
        DEC     HL
        LD      A,H
        OR      L
        JR      NZ,L09AC                ; (-07h)
        LD      A,40H
        OUT     (10H),A
        XOR     A
        RET     

L09B9:  DW      L2C00
        DW      L2C40
        DW      L2C80
        DW      L2CC0

; Initial Controller State, copied to 2D00H.
L09C1:  DB      0FFh, 0FFh, 004h, 000h, 000h, 001h, 000h, 005h
        DB      005h, 005h, 005h

L09CC:  DB      0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
        DB      0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh

L09DA:  DB      08H, 10H, 20H, 40H

; Default drive parameters
;                H   TL   TH   SPT  PCH  PCL
L09DE:  DB      0Fh, 20H, 03H, 20H, 00H, 00H, 00H, 01H          ; Original: 15 heads, 800 tracks, 32 sectors/track
;L09DE:  DB      04h, 67H, 02H, 20H, 2CH, 01H, 00H, 01H          ; Seagate ST-225: 4 heads, 615 tracks, 32 sectors/track, wpc=300

L09E6:  EXX
        PUSH    BC
        PUSH    DE
        PUSH    HL
        EXX     
        PUSH    BC
        PUSH    DE
        PUSH    HL
        LD      (IY+06H),H
        LD      (IY+05H),L
        LD      (IY+0AH),H
        LD      (IY+09H),L
        PUSH    HL
        CALL    L0234
        POP     HL
        LD      (IY+DCTRKHI),H
        LD      (IY+DCTRKLO),L
        LD      (IY+07H),L
        LD      (IY+08H),H
        LD      HL,0DB9H
        LD      C,20H
        LD      B,04H
l0a12:  LD      A,(HL)
        OUT     (C),A
        INC     HL
        INC     C
        DJNZ    L0A12                   ; (-07h)
        POP     HL
        POP     DE
        POP     BC
l0a1c:  CALL    L0A95
        JR      C,L0A44                 ; (+23h)
        INC     HL
        DEC     DE
        LD      A,E
        OR      D
        JR      Z,L0A44                 ; (+1dh)
        LD      (IY+05H),L
        LD      (IY+06H),H
        LD      (IY+09H),L
        LD      (IY+0AH),H
        LD      (IY+DCTRKHI),H
        LD      (IY+DCTRKLO),L
        LD      (IY+08H),H
        LD      (IY+07H),L
        CALL    L0AB6
        JR      L0A1C                   ; (-28h)
l0a44:  EXX     
        POP     HL
        POP     DE
        POP     BC
        EXX     
        LD      (IY+00H),0FFH
        LD      (IY+0DH),0FFH
        RET     

        LD      A,(L2DF6)
        OR      A
        JR      Z,L0A82                 ; (+2ah)
        PUSH    BC
        PUSH    DE
        PUSH    HL
        LD      HL,L0DDD
        LD      DE,2E40H
        LD      BC,0020H
        LDIR                            ; Copy 32 bytes from 0DDDH to 2E40H
        CALL    CRLFST
        POP     HL
        PUSH    HL
        LD      DE,2E47H
        LD      A,H
        CALL    L1BE0
        LD      A,L
        LD      DE,2E49H
        CALL    L1BE0
        LD      HL,2E40H
        CALL    OUTSTR
        POP     HL
        POP     DE
        POP     BC
l0a82:  LD      A,(IY+DCTRKLO)
        LD      (IY+07H),A
        LD      A,(IY+DCTRKHI)
        LD      (IY+08H),A
        LD      A,(IY+00H)
        LD      (IY+0DH),A
        RET     

l0a95:  PUSH    BC
        PUSH    DE
        PUSH    HL
        OR      A
        LD      A,C
        RLCA    
        RLCA    
        RLCA    
        RLCA    
        OR      H
        LD      H,A
        LD      B,01H
l0aa2:  CALL    L0ACB
        LD      A,(L2DF6)
        OR      A
        JR      NZ,L0AB0                ; (+05h)
        CALL    L0B29
        JR      C,L0AB2                 ; (+02h)
l0ab0:  DJNZ    L0AA2                   ; (-10h)
l0ab2:  POP     HL
        POP     DE
        POP     BC
        RET     

l0ab6:  PUSH    BC
        PUSH    DE
        PUSH    HL
        CALL    L0373
        LD      A,0CH
        CALL    L026F
l0ac1:  IN      A,(18H)
        BIT     2,A
        JR      NZ,L0AC1                ; (-06h)
        POP     HL
        POP     DE
        POP     BC
        RET     

l0acb:  EXX     
        LD      HL,0DBDH
        LD      B,(IY+DSECPT)
        LD      A,(HL)
        INC     HL
        DEC     B
        EXX     
        PUSH    BC
        LD      C,24H
        OUT     (C),L
        INC     C
        OUT     (C),H
        INC     C
        OUT     (C),A
        INC     C
        LD      A,0F8H
        OUT     (C),A
        CALL    L0BC5
        LD      A,0AH
        PUSH    AF
        OR      20H
        LD      (2D9FH),A
        POP     AF
        OUT     (1CH),A
        DEC     C
        JR      L0AFB                   ; (+04h)
l0af7:  OUT     (C),A
        JR      Z,L0B10                 ; (+15h)
l0afb:  EXX     
        LD      A,(HL)
        INC     HL
        DEC     B
        EXX     
        EX      AF,AF'
l0b01:  IN      A,(18H)
        BIT     7,A
        JR      Z,L0B01                 ; (-06h)
l0b07:  IN      A,(18H)
        BIT     7,A
        JR      NZ,L0B07                ; (-06h)
        EX      AF,AF'
        JR      L0AF7                   ; (-19h)
l0b10:  LD      A,(2D9FH)
        LD      B,A
l0b14:  IN      A,(18H)
        BIT     7,A
        JR      NZ,L0B14                ; (-06h)
        LD      A,B
        LD      B,0B9H
l0b1d:  DJNZ    L0B1D                   ; (-02h)
l0b1f:  DJNZ    L0B1F                   ; (-02h)
        OUT     (1CH),A
        EI      
l0b24:  JR      L0B24                   ; (-02h)
        EI      
        POP     BC
        RET     

l0b29:  PUSH    BC
        PUSH    DE
        PUSH    HL
        LD      HL,2012H
        LD      A,0B6H
        LD      (HL),A
        DEC     HL
        LD      A,6DH
        LD      (HL),A
        LD      DE,2013H
        LD      BC,00FEH
        LDIR    
        CALL    L0B7E
        LD      A,03H
        JR      C,L0B6C                 ; (+27h)
        CALL    L0B92
        LD      A,03H
        JR      C,L0B6C                 ; (+20h)
        LD      HL,2012H
        LD      A,49H
        LD      (HL),A
        DEC     HL
        LD      A,92H
        LD      (HL),A
        LD      DE,2013H
        LD      BC,00FEH
        LDIR    
        CALL    L0B7E
        LD      A,03H
        JR      C,L0B6C                 ; (+07h)
        CALL    L0B92
        JR      NC,L0B6C                ; (+02h)
        LD      A,03H
l0b6c:  POP     HL
        POP     DE
        POP     BC
        RET     

        LD      HL,2011H
        LD      DE,2012H
        LD      (HL),A
        LD      BC,0100H
        DEC     BC
        LDIR    
        RET     

l0b7e:  XOR     A
l0b7f:  LD      (IY+0BH),A
        CALL    L0C26
        JR      C,L0B91                 ; (+0ah)
        LD      A,(IY+0BH)
        INC     A
        CP      (IY+DSECPT)
        JR      C,L0B7F                 ; (-11h)
        XOR     A
l0b91:  RET     

l0b92:  XOR     A
l0b93:  LD      (IY+0BH),A
        CALL    L0BA6
        JR      C,L0BA5                 ; (+0ah)
        LD      A,(IY+0BH)
        INC     A
        CP      (IY+DSECPT)
        JR      C,L0B93                 ; (-11h)
        XOR     A
l0ba5:  RET     

l0ba6:  LD      HL,2DA2H
        LD      (2DA0H),HL
        CALL    L0CA3
        JR      C,L0BC4                 ; (+13h)
        LD      HL,2007H
        LD      DE,0100H
        ADD     HL,DE
        LD      A,(HL)
        INC     HL
        OR      (HL)
        INC     HL
        OR      (HL)
        INC     HL
        OR      (HL)
        JR      Z,L0BC4                 ; (+03h)
        LD      A,0AH
        SCF     
l0bc4:  RET     

l0bc5:  PUSH    HL
        PUSH    DE
        LD      L,(IY+DCTRKLO)
        LD      H,(IY+DCTRKHI)
        LD      E,(IY+DWPCLO)
        LD      D,(IY+DWPCHI)
        OR      A
        SBC     HL,DE
        LD      A,02H
        JR      NC,L0BDB                ; (+01h)
        XOR     A
l0bdb:  OUT     (14H),A
        POP     DE
        POP     HL
        RET     

l0be0:  EXX     
        PUSH    BC
        PUSH    DE
        PUSH    HL
        EXX     
        PUSH    BC
        PUSH    DE
        PUSH    HL
        LD      (IY+06H),H
        LD      (IY+05H),L
        PUSH    HL
        CALL    L0234
        POP     HL
        LD      (IY+DCTRKHI),H
        LD      (IY+DCTRKLO),L
        LD      (IY+08H),H
        LD      (IY+07H),L
        LD      HL,0DB9H
        LD      C,20H
        LD      B,03H
l0c06:  LD      A,(HL)
        OUT     (C),A
        INC     HL
        INC     C
        DJNZ    L0C06                   ; (-07h)
        LD      A,0AAH
        OUT     (C),A
        POP     HL
        POP     DE
        POP     BC
        EX      DE,HL
        LD      DE,0001H
        LD      A,B
        LD      B,01H
        LD      C,A
        CALL    L0A95
        EXX     
        POP     HL
        POP     DE
        POP     BC
        EXX     
        XOR     A
        RET     

l0c26:  OUT     (00H),A
        LD      HL,200FH
        INC     HL
        INC     HL
        LD      DE,0100H
        ADD     HL,DE
        XOR     A
        LD      B,04H
l0c34:  LD      (HL),A
        INC     HL
        DJNZ    L0C34                   ; (-04h)
        LD      HL,DATABUF
        LD      BC,200FH
        LD      B,C
        XOR     A
l0c40:  LD      (HL),A
        INC     HL
        DJNZ    L0C40                   ; (-04h)
        LD      A,0A1H
        LD      (HL),A
        INC     HL
        LD      A,0F8H
        LD      (HL),A
        CALL    L0D7A
        EXX     
        LD      B,0FEH
        LD      HL,2001H
        LD      DE,2004H
        EXX     
        LD      A,(IY+DSECPT)
        ADD     A,A
        ADD     A,A
        LD      B,A
        CALL    L0BC5
        LD      C,0CH
        LD      D,08H
l0c65:  PUSH    BC
        LD      B,C
        LD      A,05H
        LD      C,1CH
        EXX     
        OUT     (1CH),A
        LD      A,(HL)
        CP      B
        JR      NZ,L0C89                ; (+17h)
        LD      A,(DE)
        CP      C
        JR      NZ,L0C89                ; (+13h)
        EXX     
        OUT     (C),D
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        OUT     (C),B
        NOP     
        JR      L0C98                   ; (+0fh)
l0c89:  EXX     
        LD      A,08H
        OUT     (1CH),A
        OUT     (00H),A
        POP     BC
        DJNZ    L0C65                   ; (-2eh)
        LD      A,07H
        SCF     
        JR      L0CA2                   ; (+0ah)
l0c98:  LD      A,08H
        OUT     (1CH),A
        OUT     (00H),A
        CALL    L0D50
        POP     BC
l0ca2:  RET     

l0ca3:  LD      A,08H
        OUT     (1CH),A
        OUT     (00H),A
        CALL    L0D7A
        EXX     
        LD      B,0FEH
        LD      HL,2001H
        LD      DE,2004H
        EXX     
        LD      A,(IY+DSECPT)
        ADD     A,A
        LD      B,A
        ADD     A,A
        ADD     A,B
        LD      B,A
        LD      C,09H
        LD      D,08H
l0cc2:  PUSH    BC
        LD      A,C
        EX      AF,AF'
        LD      A,05H
        LD      C,1CH
        OUT     (1CH),A
        OUT     (C),D
        EXX     
        LD      A,(HL)
        CP      B
        JR      NZ,L0CEC                ; (+1ah)
        LD      A,(DE)
        CP      C
        JR      NZ,L0CEC                ; (+16h)
        EXX     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        NOP     
        EX      AF,AF'
        OUT     (1CH),A
        EX      AF,AF'
        OUT     (C),D
        NOP     
        JR      L0CF7                   ; (+0bh)
l0cec:  EXX     
        OUT     (00H),A
        POP     BC
        DJNZ    L0CC2                   ; (-30h)
        LD      A,07H
        SCF     
        JR      L0D3A                   ; (+43h)
l0cf7:  OUT     (00H),A
        POP     BC
        CALL    L0D50
        JR      C,L0D3A                 ; (+3bh)
        LD      HL,2005H
        LD      A,(HL)
        CP      0A1H
        LD      A,07H
        SCF     
        JR      NZ,L0D3A                ; (+30h)
        INC     HL
        LD      A,(HL)
        CP      0F8H
        LD      A,07H
        SCF     
        JR      NZ,L0D3A                ; (+27h)
        INC     HL
        LD      DE,0100H
        ADD     HL,DE
        LD      A,(2D1AH)
        OR      A
        JR      NZ,L0D2D                ; (+0fh)
        XOR     A
        OR      (HL)
        INC     HL
        OR      (HL)
        INC     HL
        OR      (HL)
        INC     HL
        OR      (HL)
        JR      Z,L0D3A                 ; (+12h)
        LD      A,04H
        SCF     
        JR      L0D3A                   ; (+0dh)
l0d2d:  LD      DE,(2DA0H)
        LD      BC,L0004
        LDIR    
        LD      (2DA0H),DE
l0d3a:  RET     

l0d3b:  LD      HL,DATABUF
        OUT     (00H),A
        LD      A,05H
        OUT     (1CH),A
        PUSH    BC
        LD      B,02H
l0d47:  DJNZ    L0D47                   ; (-02h)
        POP     BC
        OR      A
        LD      A,08H
        OUT     (1CH),A
        RET     

l0d50:  LD      HL,DATABUF
        LD      A,(HL)
        CP      0A1H
        JR      NZ,L0D6A                ; (+12h)
        INC     HL
        INC     HL
        LD      DE,2D80H
        LD      B,03H
l0d5f:  LD      A,(DE)
        CP      (HL)
        JR      NZ,L0D6A                ; (+07h)
        INC     HL
        INC     DE
        DJNZ    L0D5F                   ; (-08h)
        XOR     A
        JR      L0D79                   ; (+0fh)
l0d6a:  LD      (IY+07H),0FFH
        LD      (IY+08H),0FFH
        LD      (IY+0DH),0FFH
        LD      A,03H
        SCF     
l0d79:  RET     

l0d7a:  PUSH    HL
        PUSH    DE
        LD      HL,2D80H
        LD      E,(IY+DCTRKLO)
        LD      (HL),E
        INC     HL
        LD      D,(IY+DCTRKHI)
        LD      A,(IY+00H)
        OR      A
        RLCA    
        RLCA    
        RLCA    
        RLCA    
        OR      D
        LD      (HL),A
        INC     HL
        LD      A,(2D1AH)
        OR      A
        JR      NZ,L0DAF                ; (+17h)
        LD      A,(2DF5H)
        CP      09H
        JR      NZ,L0DAF                ; (+10h)
        LD      IX,175AH
        LD      E,(IY+0BH)
        LD      D,00H
        ADD     IX,DE
        LD      A,(IX+00H)
        JR      L0DB2                   ; (+03h)
l0daf:  LD      A,(IY+0BH)
l0db2:  LD      (HL),A
        EXX     
        LD      C,A
        EXX     
        POP     DE
        POP     HL
        RET     

        LD      C,(HL)
        NOP     
        AND     C
        CP      00H
        EX      AF,AF'
        DJNZ    L0DD9                   ; (+18h)
        LD      BC,1109H
        ADD     HL,DE
        LD      (BC),A
        LD      A,(BC)
        LD      (DE),A
        LD      A,(DE)
        INC     BC
        DEC     BC
        INC     DE
        DEC     DE
        INC     B
        INC     C
        INC     D
        INC     E
        DEC     B
        DEC     C
        DEC     D
        DEC     E
        LD      B,0EH
        LD      D,1EH
l0dd9:  RLCA    
        RRCA    
        RLA     
        RRA     
L0DDD:  DB      11H, 'Track ', 0, 0, 0, 0, ' is bad '

L0DF0:  LD      A,(2D26h)
        LD      B,A
        LD      C,00h
        LD      HL,2DA2h
        LD      E,C
        LD      D,00h
        ADD     HL,DE
        ADD     HL,DE
        ADD     HL,DE
        ADD     HL,DE
        PUSH    HL
        LD      A,(HL)
        INC     HL
        OR      (HL)
        INC     HL
        OR      (HL)
        INC     HL
        OR      (HL)
        POP     HL
        JR      Z,L0E19                 ; (+0eh)
        LD      DE,(2D06H)
        INC     DE
        LD      (2D06H),DE
        CALL    L0E28
        JR      C,L0E27                 ; (+0eh)
l0e19:  LD      HL,(2D92H)
        LD      DE,0100H
        ADD     HL,DE
        LD      (2D92H),HL
        INC     C
        DJNZ    0DF6H                   ; (-30h)
        XOR     A
l0e27:  RET     

l0e28:  PUSH    BC
        LD      A,01H
l0e2b:  LD      (2D05H),A
        LD      A,(L2D18)
        OR      A
        LD      A,04H
        SCF     
        JP      Z,L0EAC
        LD      A,(2D24H)
        ADD     A,C
        LD      (IY+0BH),A
        LD      DE,2DCAH
        LD      BC,L0004
        LDIR    
        LD      (2DA0H),DE
        LD      B,05H
        LD      C,01H
l0e4f:  PUSH    BC
        CALL    L0CA3
l0e53:  POP     BC
        JP      C,L0EAC
        LD      HL,(2DA0H)
        DEC     HL
        LD      A,(HL)
        DEC     HL
        OR      (HL)
        DEC     HL
        OR      (HL)
        DEC     HL
        OR      (HL)
        JR      Z,L0E72                 ; (+0eh)
        CALL    L0EAE
        JR      NC,L0E89                ; (+20h)
        INC     C
        DJNZ    L0E4F                   ; (-1dh)
        LD      A,04H
        SCF     
        JP      L0EAC
l0e72:  LD      A,(2D26H)
        DEC     A
        JP      Z,L0EAC
        LD      HL,2007H
        LD      DE,(2D92H)
        LD      BC,0100H
        LDIR    
        XOR     A
        JP      L0EAC
l0e89:  DEC     A
        JR      Z,L0E9E                 ; (+12h)
        LD      A,(2D26H)
        DEC     A
        JR      Z,L0E9E                 ; (+0ch)
        LD      HL,2007H
        LD      DE,(2D92H)
        LD      BC,0100H
        LDIR    
l0e9e:  LD      HL,(2DA0H)
        DEC     HL
        LD      E,(HL)
        DEC     HL
        LD      D,(HL)
        DEC     HL
        LD      C,(HL)
        DEC     HL
        LD      B,(HL)
        CALL    L0EDA
l0eac:  POP     BC
        RET     

l0eae:  PUSH    BC
        LD      B,C
        LD      C,01H
        LD      DE,2DCAH
l0eb5:  PUSH    HL
        PUSH    DE
        PUSH    BC
        LD      B,04H
l0eba:  LD      A,(DE)
        CP      (HL)
        JR      NZ,L0ECD                ; (+0fh)
        INC     HL
        INC     DE
        DJNZ    L0EBA                   ; (-08h)
        POP     BC
        POP     DE
        POP     HL
        LD      A,C
        DEC     C
        JR      Z,L0ECA                 ; (+01h)
        XOR     A
l0eca:  OR      A
        JR      L0ED8                   ; (+0bh)
l0ecd:  POP     BC
        POP     DE
        POP     HL
        INC     DE
        INC     DE
        INC     DE
        INC     DE
        INC     C
        DJNZ    L0EB5                   ; (-22h)
        SCF     
l0ed8:  POP     BC
        RET     

l0eda:  LD      HL,0807H
        EX      AF,AF'
        XOR     A
        EX      AF,AF'
l0ee0:  LD      A,B
        OR      A
        JR      NZ,L0EF1                ; (+0dh)
        PUSH    DE
        LD      DE,0008H
        ADD     HL,DE
        POP     DE
        LD      B,C
        LD      C,D
        LD      D,E
        LD      E,00H
        JR      L0EE0                   ; (-11h)
l0ef1:  XOR     A
        RR      B
        RR      C
        RR      D
        RR      E
        JR      NC,L0F0C                ; (+10h)
        LD      A,22H
        XOR     E
        LD      E,A
        LD      A,02H
        XOR     D
        LD      D,A
        LD      A,05H
        XOR     C
        LD      C,A
        LD      A,8AH
        XOR     B
        LD      B,A
l0f0c:  LD      A,B
        OR      A
        JR      NZ,L0F2C                ; (+1ch)
        EX      AF,AF'
        PUSH    AF
        EX      AF,AF'
        POP     AF
        OR      A
        JR      NZ,L0F25                ; (+0eh)
        LD      A,D
        OR      E
        JR      NZ,L0F2C                ; (+11h)
        LD      A,07H
        AND     C
        JR      NZ,L0F2C                ; (+0ch)
        EX      AF,AF'
        XOR     A
        NEG     
        EX      AF,AF'
l0f25:  LD      A,L
        AND     07H
        JR      NZ,L0F31                ; (+07h)
        JR      L0F35                   ; (+09h)
l0f2c:  LD      A,H
        OR      L
        JP      Z,L0F51
l0f31:  DEC     HL
        JP      L0EF1
l0f35:  PUSH    BC
        LD      B,03H
        XOR     A
l0f39:  RR      H
        RR      L
        DJNZ    L0F39                   ; (-06h)
        POP     BC
        PUSH    DE
        LD      DE,(2D92H)
        ADD     HL,DE
        POP     DE
        LD      A,(HL)
        XOR     C
        LD      (HL),A
        INC     HL
        LD      A,(HL)
        XOR     D
        LD      (HL),A
        XOR     A
        JR      L0F54                   ; (+03h)
l0f51:  LD      A,04H
        SCF     
l0f54:  RET     

L0F55:  LD      DE,2007H
        LD      (2D92H),DE
        LD      HL,2107H
        LD      B,(HL)
        INC     HL
        LD      C,(HL)
        INC     HL
        LD      D,(HL)
        INC     HL
        LD      E,(HL)
        CALL    L0EDA
        RET     C

        LD      HL,DATABUF
        LD      B,14H
        JP      DUMPHEX

; Read Drive Parameters?
L0F72:  PUSH    IY
        LD      HL,206CH
        LD      DE,DATABUF
        XOR     A
        SBC     HL,DE
        LD      C,L
        LD      B,H
        EX      DE,HL
        DEC     A
        LD      (HL),A
        LD      DE,2001H
        LDIR    
        LD      BC,0000
        LD      (2020H),BC
        LD      (2022H),BC
        LD      (202EH),BC
        LD      A,02H
        LD      (206CH),A
        XOR     A
        LD      (L2D21),A
        LD      B,04H
l0fa1:  CALL    L0FB3
        LD      A,(L2D21)
        INC     A
        LD      (L2D21),A
        DJNZ    L0FA1                   ; (-0ch)
        XOR     A
        OUT     (00H),A
        POP     IY
        RET     

l0fb3:  PUSH    BC
        CALL    L069B
        LD      A,(IY+DONLINE)
        OR      A
        JP      NZ,L1031
        LD      E,(IY+DHEADS)
        LD      D,00H
        LD      (2024H),DE
        LD      (202CH),DE
        LD      E,(IY+DSECPT)
        LD      (2028H),DE
        LD      E,(IY+DMTRKLO)
        LD      D,(IY+DMTRKHI)
        DEC     DE
        DEC     DE
        DEC     DE
        LD      (2026H),DE
        LD      (202AH),DE
        LD      A,(L2D21)
        CP      03H
        JR      NZ,L0FEF                ; (+05h)
        LD      A,07H
        LD      (206CH),A
l0fef:  LD      A,(206CH)
        CP      08H
        JP      NC,L1031
        LD      DE,(2024H)
        LD      HL,0FFFFH
        CALL    L1033
        LD      DE,(2028H)
        CALL    L1033
        LD      DE,(2026H)
        XOR     A
        LD      BC,0000
        SBC     HL,DE
        JR      NC,L1018                ; (+04h)
        ADD     HL,DE
        LD      (2026H),HL
l1018:  PUSH    DE
        LD      HL,(2026H)
        LD      DE,0000
l101f:  CALL    L104D
        EX      DE,HL
        ADD     HL,DE
        EX      DE,HL
        EX      (SP),HL
        LD      HL,(202AH)
        SBC     HL,DE
        EX      (SP),HL
        JR      Z,L1030                 ; (+02h)
        JR      NC,L101F                ; (-11h)
l1030:  POP     DE
l1031:  POP     BC
        RET     

l1033:  PUSH    BC
        LD      A,E
        OR      D
        JR      Z,L104A                 ; (+12h)
        LD      BC,0000
l103b:  SBC     HL,DE
        JR      C,L1043                 ; (+04h)
        INC     BC
        OR      A
        JR      L103B                   ; (-08h)
l1043:  ADD     HL,DE
        EX      DE,HL
        LD      L,C
        LD      H,B
        OR      A
        JR      L104B                   ; (+01h)
l104a:  SCF     
l104b:  POP     BC
        RET     

l104d:  PUSH    BC
        PUSH    HL
        PUSH    DE
        LD      A,(206CH)
        CP      08H
        JR      Z,L108F                 ; (+38h)
        LD      L,A
        LD      H,00H
        ADD     HL,HL
        ADD     HL,HL
        LD      DE,DATABUF
        ADD     HL,DE
        LD      A,(L2D21)
        LD      (HL),A
        INC     HL
        POP     DE
        PUSH    DE
        LD      (HL),E
        INC     HL
        LD      (HL),D
        INC     HL
        LD      (HL),C
        LD      A,(206CH)
        INC     A
        LD      (206CH),A
        LD      A,E
        OR      D
        JR      NZ,L108F                ; (+18h)
        LD      A,(L2D21)
        ADD     A,A
        LD      B,A
        ADD     A,A
        ADD     A,A
        ADD     A,B
        LD      E,A
        LD      D,00H
        LD      HL,2030H
        ADD     HL,DE
        EX      DE,HL
        LD      HL,2024H
        LD      BC,000AH
        LDIR    
l108f:  POP     DE
        POP     HL
        POP     BC
        RET     

        XOR     A
        OUT     (2FH),A
        LD      A,02H
        OUT     (2FH),A
        LD      B,08H
l109c:  DJNZ    L109C                   ; (-02h)
        XOR     A
        OUT     (2FH),A
        RET     

        RET     

RWCMD:  IN      A,(2FH)
        BIT     7,A
        JR      Z,L10B1                 ; (+08h)
        AND     60H
        JR      Z,L10B1                 ; (+04h)
        CP      60H
        JR      NZ,RWCMD                ; (-0eh)
l10b1:  XOR     A
        OUT     (2FH),A
        OUT     (2EH),A
        IN      A,(2EH)
        LD      A,02H
        OUT     (2FH),A
        LD      B,08H
l10be:  DJNZ    L10BE                   ; Delay loop 8 times
        XOR     A
        OUT     (2FH),A
        CALL    L120E
        LD      A,11H
        CALL    L12C9
        CALL    L120E
        RET     

TMCMD:  IN      A,(2FH)
        LD      B,A
        IN      A,(2FH)
        CP      B
        JR      NZ,TMCMD                ; (-08h)
        AND     60H
        JR      Z,L10DF                 ; (+04h)
        CP      60H
        JR      NZ,TMCMD                ; (-10h)
l10df:  IN      A,(2FH)
        AND     01H
        JR      Z,L10DF                 ; (-06h)
        LD      A,05H
        OUT     (2FH),A
        LD      A,60H
        CALL    L128B
        XOR     A
        RET     

        LD      A,0A0H
        JP      L10F5
l10f5:  PUSH    AF
l10f6:  IN      A,(2FH)
        AND     18H
        JR      NZ,L10F6                ; (-06h)
        LD      A,05H
        OUT     (2FH),A
        POP     AF
        PUSH    AF
        CALL    L128B
        POP     AF
        CP      60H
        JR      Z,L1113                 ; (+09h)
l110a:  IN      A,(2FH)
        AND     02H
        JR      Z,L110A                 ; (-06h)
        CALL    L120E
l1113:  RET     

WTCMD:  IN      A,(2FH)
        AND     02H
        JP      NZ,L12B3
        IN      A,(2FH)
        AND     08H
        CALL    Z,L12BF
        CALL    NZ,L12C4
        LD      B,00H
        CALL    L1457
        IN      A,(2FH)
        AND     08H
        CALL    Z,L12BF
        CALL    NZ,L12C4
        IN      A,(2FH)
        AND     18H
        JR      NZ,L1141                ; (+07h)
        LD      A,40H
        CALL    L128B
        OUT     (2EH),A
l1141:  IN      A,(2FH)
        AND     08H
        JR      Z,L1169                 ; (+22h)
l1147:  IN      A,(2FH)
        AND     02H
        JP      NZ,L12B3
        IN      A,(2FH)
        AND     20H
        JR      NZ,L1147                ; (-0dh)
        IN      A,(2FH)
        AND     02H
        JP      NZ,L12B3
        LD      A,04H
        OUT     (2FH),A
        LD      A,44H
        OUT     (2FH),A
        LD      A,54H
        OUT     (2FH),A
        XOR     A
        RET     

l1169:  IN      A,(2FH)
        AND     18H
        JR      Z,L117C                 ; (+0dh)
l116f:  IN      A,(2FH)
        AND     02H
        JP      NZ,L12B3
        IN      A,(2FH)
        AND     40H
        JR      NZ,L116F                ; (-0dh)
l117c:  IN      A,(2FH)
        AND     02H
        JP      NZ,L12B3
        LD      A,04H
        OUT     (2FH),A
        LD      A,24H
        OUT     (2FH),A
        LD      A,2CH
        OUT     (2FH),A
        XOR     A
        RET     

l1191:  IN      A,(2FH)
        AND     08H
        CALL    Z,L12BF
        CALL    NZ,L12C4
        IN      A,(2FH)
        AND     18H
        JR      NZ,L11AF                ; (+0eh)
        LD      A,80H
        CALL    L128B
        OUT     (2EH),A
        IN      A,(2FH)
        AND     02H
        JP      NZ,L12B3
l11af:  IN      A,(2FH)
        AND     08H
        JR      NZ,L11E8                ; (+33h)
        IN      A,(2FH)
        AND     18H
        LD      (2DF9H),A
        JR      Z,L11CE                 ; (+10h)
l11be:  IN      A,(2FH)
        AND     40H
        JR      Z,L11CE                 ; (+0ah)
        IN      A,(2FH)
        AND     02H
        JP      Z,L11BE
        JP      L12B3
l11ce:  LD      A,04H
        OUT     (2FH),A
        LD      A,24H
        OUT     (2FH),A
        LD      A,2CH
        OUT     (2FH),A
        IN      A,(2EH)
        LD      C,30H
        LD      A,(2DF9H)
        CP      00H
        JR      Z,L1191                 ; (-54h)
        JP      L1207
l11e8:  IN      A,(2FH)
        AND     20H
        JR      Z,L11F7                 ; (+09h)
        IN      A,(2FH)
        AND     02H
        JR      Z,L11E8                 ; (-0ch)
        JP      L12B3
l11f7:  LD      A,04H
        OUT     (2FH),A
        LD      A,44H
        OUT     (2FH),A
        LD      A,54H
        OUT     (2FH),A
        OUT     (2EH),A
        LD      C,2DH
l1207:  LD      B,00H
        CALL    L1581
        XOR     A
        RET     

l120e:  LD      A,00H
        LD      (2DF8H),A
l1213:  IN      A,(2FH)
        AND     03H
        JR      Z,L1213                 ; (-06h)
        LD      A,0C0H
        CALL    L12C9
        DI      
l121f:  IN      A,(2FH)
        AND     04H
        JR      Z,L121F                 ; (-06h)
l1225:  IN      A,(2FH)
        AND     01H
        JR      Z,L1225                 ; (-06h)
        IN      A,(2CH)
        PUSH    AF
        IN      A,(2FH)
        AND     80H
        JR      Z,L1236                 ; (+02h)
        LD      A,04H
l1236:  OR      01H
        OUT     (2FH),A
l123a:  IN      A,(2FH)
        AND     01H
        JR      NZ,L123A                ; (-06h)
        IN      A,(2FH)
        AND     80H
        JR      Z,L1248                 ; (+02h)
        LD      A,04H
l1248:  OUT     (2FH),A
        EI      
        LD      A,(2DF8H)
        CP      02H
        JR      NC,L1256                ; (+04h)
        POP     AF
        PUSH    AF
        LD      B,C
        LD      C,A
l1256:  POP     AF
        LD      A,(2DF8H)
        INC     A
        LD      (2DF8H),A
        IN      A,(2FH)
        AND     04H
        JR      NZ,L1225                ; (-3fh)
        LD      A,B
        AND     60H
        LD      A,09H
        RET     NZ

        BIT     4,B
        LD      A,0AH
        RET     NZ

        BIT     3,B
        LD      A,0DH
        RET     NZ

        LD      A,B
        AND     06H
        LD      A,0CH
        RET     NZ

        BIT     0,B
        LD      A,0BH
        RET     NZ

        BIT     5,C
        LD      A,0FH
        RET     NZ

        BIT     6,C
        SCF     
        RET     NZ

        XOR     A
        RET     

        XOR     A
l128b:  DI      
        CPL     
        OUT     (2CH),A
        LD      A,04H
        OUT     (2FH),A
        LD      A,05H
        OUT     (2FH),A
        LD      B,14H
l1299:  DJNZ    L1299                   ; (-02h)
l129b:  IN      A,(2FH)
        AND     01H
        JR      Z,L129B                 ; (-06h)
        LD      A,04H
        OUT     (2FH),A
l12a5:  IN      A,(2FH)
        AND     01H
        JR      NZ,L12A5                ; (-06h)
l12ab:  IN      A,(2FH)
        AND     03H
        JR      Z,L12AB                 ; (-06h)
        EI      
        RET     

l12b3:  LD      A,04H
        OUT     (2FH),A
        IN      A,(2EH)
        OUT     (2EH),A
        CALL    L120E
        RET     

l12bf:  OUT     (2EH),A
        LD      C,2DH
        RET     

l12c4:  IN      A,(2EH)
        LD      C,30H
        RET     

l12c9:  DI      
        CPL     
        OUT     (2CH),A
        IN      A,(2FH)
        AND     80H
        JR      Z,L12D5                 ; (+02h)
        LD      A,04H
l12d5:  OR      01H
        OUT     (2FH),A
l12d9:  IN      A,(2FH)
        AND     01H
        JR      Z,L12D9                 ; (-06h)
        IN      A,(2FH)
        AND     80H
        JR      Z,L12E7                 ; (+02h)
        LD      A,04H
l12e7:  OUT     (2FH),A
l12e9:  IN      A,(2FH)
        AND     01H
        JR      NZ,L12E9                ; (-06h)
        EI      
        RET     

l12f1:  LD      HL,DATABUF
        LD      DE,2200H
        LD      BC,0020H
        LDIR    
        CALL    L139B
        JP      C,L1379
        INC     C
        PUSH    BC
        CALL    DODSC
        POP     BC
l1308:  PUSH    BC
        CALL    WTCMD
        POP     BC
        JR      NZ,L1372                ; (+63h)
        DJNZ    L1308                   ; (-09h)
        DEC     C
        JR      NZ,L1308                ; (-0ch)
        JR      L1362                   ; (+4ch)
l1316:  CALL    L139B
        JR      C,L1379                 ; (+5eh)
        INC     C
        PUSH    BC
        CALL    L1191
        POP     BC
        JR      NZ,L1372                ; (+4fh)
        LD      A,(2025H)
        LD      (2DF5H),A
        XOR     A
        LD      (2025H),A
        LD      HL,(2026H)
        LD      DE,(2D22H)
        OR      A
        SBC     HL,DE
        LD      A,H
        OR      L
        JR      NZ,L1370                ; (+35h)
        LD      A,(2022H)
        SUB     (IY+DHEADS)
        JR      NZ,L1370                ; (+2dh)
        LD      HL,(2028H)
        LD      DE,(2D1EH)
        OR      A
        SBC     HL,DE
        JR      C,L1370                 ; (+21h)
        JR      L135D                   ; (+0ch)
l1351:  PUSH    BC
        LD      A,05H
        LD      (2D05H),A
        CALL    L1191
        POP     BC
        JR      NZ,L1372                ; (+15h)
l135d:  DJNZ    L1351                   ; (-0eh)
        DEC     C
        JR      NZ,L1351                ; (-11h)
l1362:  LD      DE,DATABUF
        LD      HL,2600H
        LD      BC,0401H
        LDIR    
        XOR     A
        JR      L1379                   ; (+09h)
l1370:  LD      A,05H
l1372:  LD      HL,(2D22H)
        LD      (DATABUF),HL
        SCF     
l1379:  PUSH    AF
        LD      A,0FFH
        LD      (2D1AH),A
        LD      A,01H
        LD      (2D05H),A
        POP     AF
        OUT     (00H),A
        RET     

GLCMD:  XOR     A
        LD      (2D1AH),A
        LD      (2D1BH),A
        CALL    RWCMD
        CALL    L1191
        LD      (2100H),A
        XOR     A
        JR      L1379                   ; (-22h)
l139b:  XOR     A
        LD      (2D1AH),A
        LD      (2300H),A
        LD      (2600H),A
        LD      (2D1BH),A
        LD      (L2D25),A
        LD      (2D24H),A
        LD      (2D35H),A
        CALL    L0604
        LD      A,(IY+DHEADS)
        CP      0FH
        JR      Z,L1411                 ; (+56h)
        LD      HL,(2D22H)
        LD      E,(IY+DMTRKLO)
        LD      D,(IY+DMTRKHI)
        OR      A
        SBC     HL,DE
        LD      A,05H
        JR      NC,L1411                ; (+46h)
        ADD     HL,DE
        EX      DE,HL
        OR      A
        SBC     HL,DE
        LD      DE,(2D26H)
        OR      A
        SBC     HL,DE
        JR      C,L1411                 ; (+38h)
        LD      L,(IY+DMTRKLO)
        LD      H,(IY+DMTRKHI)
        DEC     HL
        LD      (2D30H),HL
        LD      (IY+0BH),00H
        CALL    L0194
        JR      C,L1411                 ; (+25h)
        CALL    RWCMD
        OR      A
        JR      NZ,L1411                ; (+1fh)
        LD      DE,(2D26H)
        LD      (2D1EH),DE
        LD      A,10H
        LD      (2D26H),A
        LD      (2D94H),A
        LD      HL,0000
        LD      B,(IY+DHEADS)
l1408:  ADD     HL,DE
        DJNZ    L1408                   ; (-03h)
        ADD     HL,HL
        INC     HL
        ADD     HL,DE
        LD      C,H
        LD      B,L
        RET     

l1411:  PUSH    AF
        LD      A,0FFH
        LD      (2D1AH),A
        POP     AF
        SCF     
        RET     

DODSC:  CALL    DSCMD
        RET     C

        LD      HL,2200H
        LD      DE,DATABUF
        LD      BC,0020H
        LDIR    
        LD      HL,(2D22H)
        LD      (2026H),HL
        LD      HL,(2D1EH)
        LD      (2028H),HL
        LD      L,(IY+DMTRKLO)
        LD      H,(IY+DMTRKHI)
        LD      (2020H),HL
        LD      L,(IY+DHEADS)
        LD      H,00H
        LD      (2022H),HL
        LD      A,(L2D21)
        LD      L,A
        LD      (202AH),HL
        LD      A,(2DF5H)
        LD      H,A
        LD      L,20H
        LD      (2024H),HL
        RET     

l1457:  LD      A,(2D1BH)
        OR      A
        JR      NZ,L1468                ; (+0bh)
        DEC     A
        LD      (2D1BH),A
        LD      HL,DATABUF
        OTIR    
        XOR     A
        RET     

l1468:  LD      (2D1CH),BC
l146c:  IN      A,(18H)
        BIT     2,A
        JR      NZ,L146C                ; (-06h)
        CALL    L0373
l1475:  CALL    L0D3B
        LD      A,(HL)
        CP      0A1H
        JR      NZ,L1487                ; (+0ah)
        INC     HL
        LD      A,(HL)
        CP      0F8H
        JR      Z,L1475                 ; (-0eh)
        CP      0FEH
        JR      Z,L148D                 ; (+06h)
l1487:  CALL    L0194
        JP      C,L1534
l148d:  CALL    L0780
        JP      C,L1543
l1493:  LD      A,10H
        LD      (2D26H),A
        LD      (2D94H),A
        LD      A,(2D24H)
        ADD     A,10H
        LD      (2D24H),A
        LD      (IY+0BH),A
        CP      (IY+DSECPT)
        JP      C,L152E
        XOR     A
        LD      (2D24H),A
        LD      (IY+0BH),A
        LD      A,(L2D25)
        INC     A
        LD      (L2D25),A
        LD      (IY+0CH),A
        LD      (IY+04H),A
        CP      (IY+DHEADS)
        JR      NC,L14D8                ; (+13h)
        LD      A,(IY+19H)
        OR      A
        JR      NZ,L14D0                ; (+05h)
        CALL    L1656
        JR      L152E                   ; (+5eh)
l14d0:  CALL    L0604
        CALL    L0194
        JR      L152E                   ; (+56h)
l14d8:  LD      HL,(2D22H)
        INC     HL
        LD      (2D22H),HL
        LD      DE,(2D30H)
        INC     DE
        OR      A
        SBC     HL,DE
        JR      NC,L152E                ; (+45h)
        XOR     A
        LD      (L2D25),A
        LD      (IY+0CH),A
        LD      (IY+04H),A
        LD      A,(IY+19H)
        OR      A
        JR      Z,L1501                 ; (+08h)
        CALL    L0604
        CALL    L0194
        JR      L1524                   ; (+23h)
l1501:  CALL    L1656
        LD      A,0CH
        CALL    L026F
        LD      HL,(2D22H)
        LD      (IY+09H),L
        LD      (IY+05H),L
        LD      (IY+07H),L
        LD      (IY+DCTRKLO),L
        LD      (IY+0AH),H
        LD      (IY+06H),H
        LD      (IY+08H),H
        LD      (IY+DCTRKHI),H
l1524:  LD      A,(2D35H)
        OR      A
        JR      NZ,L152E                ; (+04h)
        XOR     A
        LD      (2D1BH),A
l152e:  XOR     A
        LD      BC,(2D1CH)
        RET     

l1534:  LD      A,(2D05H)
        DEC     A
        JP      Z,L1493
        LD      (2D05H),A
        CALL    L169D
        JR      L157A                   ; (+37h)
l1543:  CP      04H
        CALL    NZ,L169D
        LD      A,(2D05H)
        DEC     A
        JR      Z,L1559                 ; (+0bh)
        LD      (2D05H),A
        LD      A,(2D94H)
        LD      (2D26H),A
        JR      L157A                   ; (+21h)
l1559:  CALL    L16B1
        LD      A,05H
        LD      (2D05H),A
        LD      A,(2D94H)
        DEC     A
        JP      Z,L1493
        LD      (2D94H),A
        LD      (2D26H),A
        LD      HL,2007H
        LD      BC,(2D1CH)
        OTIR    
        INC     (IY+0BH)
l157a:  LD      BC,(2D1CH)
        JP      L1457
l1581:  LD      A,(2D1BH)
        OR      A
        JR      Z,L15A0                 ; (+19h)
        LD      A,(2D35H)
        OR      A
        JR      Z,L15B8                 ; (+2bh)
        PUSH    BC
        LD      B,A
        LD      A,(2D34H)
        CP      B
        POP     BC
        JR      Z,L159C                 ; (+06h)
        INC     A
        LD      (2D34H),A
        JR      L15B8                   ; (+1ch)
l159c:  XOR     A
        LD      (2D34H),A
l15a0:  DEC     A
        LD      (2D1BH),A
        LD      HL,DATABUF
        INIR    
        LD      B,0FH
l15ab:  PUSH    BC
        LD      B,00H
        LD      HL,2100H
        INIR    
        POP     BC
        DJNZ    L15AB                   ; (-0bh)
        XOR     A
        RET     

l15b8:  LD      (2D1CH),BC
        LD      A,(2DF2H)
        OR      A
        RET     NZ

l15c1:  IN      A,(18H)
        BIT     2,A
        JR      NZ,L15C1                ; (-06h)
        CALL    L0373
l15ca:  CALL    L0D3B
        LD      A,(HL)
        CP      0A1H
        JR      NZ,L15DC                ; (+0ah)
        INC     HL
        LD      A,(HL)
        CP      0F8H
        JR      Z,L15CA                 ; (-0eh)
        CP      0FEH
        JR      Z,L15E1                 ; (+05h)
l15dc:  CALL    L0194
        JR      C,L1625                 ; (+44h)
l15e1:  LD      DE,(2002H)
        LD      A,D
        RRCA    
        RRCA    
        RRCA    
        RRCA    
        AND     0FH
        LD      C,A
        LD      A,D
        AND     0FH
        LD      D,A
        LD      HL,(2D22H)
        OR      A
        SBC     HL,DE
        JR      Z,L15FE                 ; (+05h)
        CALL    L1679
        JR      L161D                   ; (+1fh)
l15fe:  LD      A,(2300H)
        OR      A
        JR      Z,L161D                 ; (+19h)
        LD      B,A
        LD      HL,2301H
l1608:  LD      E,(HL)
        INC     HL
        LD      D,(HL)
        INC     HL
        LD      A,(HL)
        INC     HL
        SUB     C
        JR      NZ,L161B                ; (+0ah)
        PUSH    HL
        LD      HL,(2D22H)
        SBC     HL,DE
        POP     HL
        JP      Z,L1493
l161b:  DJNZ    L1608                   ; (-15h)
l161d:  CALL    L0809
        JP      NC,L1493
        JR      L1639                   ; (+14h)
l1625:  LD      A,(2D05H)
        DEC     A
        JP      Z,L1493
        LD      (2D05H),A
        CALL    L169D
        LD      BC,(2D1CH)
        JP      L1581
l1639:  CALL    L169D
        CALL    L16B1
        LD      A,(2D94H)
        DEC     A
        JP      Z,L1493
        LD      (2D94H),A
        LD      (2D26H),A
        LD      BC,(2D1CH)
        INC     (IY+0BH)
        JP      L1581
l1656:  LD      C,(IY+04H)
        BIT     3,C
        JR      Z,L1661                 ; (+04h)
        LD      A,C
        XOR     88H
        LD      C,A
l1661:  LD      HL,L09DA
        LD      A,(L2D21)
        LD      E,A
        LD      D,00H
        ADD     HL,DE
        LD      A,(HL)
        OR      C
        OUT     (10H),A
        LD      C,(IY+04H)
        LD      (IY+00H),C
        LD      (IY+0DH),C
        RET     

l1679:  LD      A,(2D24H)
        OR      A
        RET     NZ

        PUSH    DE
        LD      HL,2301H
        LD      A,(2300H)
        OR      A
        JR      Z,L168F                 ; (+07h)
        LD      DE,0003H
        LD      B,A
l168c:  ADD     HL,DE
        DJNZ    L168C                   ; (-03h)
l168f:  POP     DE
        LD      (HL),E
        INC     HL
        LD      (HL),D
        INC     HL
        LD      (HL),C
        LD      A,(2300H)
        INC     A
        LD      (2300H),A
        RET     

l169d:  LD      (IY+07H),0FFH
        LD      (IY+08H),0FFH
        LD      (IY+DCTRKLO),0FFH
        LD      (IY+DCTRKHI),0FFH
        CALL    L0194
        RET     

l16b1:  LD      A,(2600H)
        INC     A
        JR      Z,L16D8                 ; (+21h)
        LD      (2600H),A
        LD      HL,2601H
        DEC     A
        JR      Z,L16C7                 ; (+07h)
        LD      B,A
        LD      DE,L0004
l16c4:  ADD     HL,DE
        DJNZ    L16C4                   ; (-03h)
l16c7:  LD      DE,(2D22H)
        LD      (HL),E
        INC     HL
        LD      (HL),D
        INC     HL
        LD      A,(L2D25)
        LD      (HL),A
        INC     HL
        LD      A,(IY+0BH)
        LD      (HL),A
l16d8:  RET     

RTCMD:  LD      A,01H
        LD      (2DF2H),A
        CALL    L1191
        PUSH    AF
        XOR     A
        LD      (2DF2H),A
        LD      HL,1000H
        LD      (2DF3H),HL
        POP     AF
        JR      Z,L16FB                 ; (+0ch)
        CALL    L19CF
        RET     

DUCMD:  LD      HL,(2DF3H)
        LD      A,H
        OR      L
        CALL    Z,L1718
l16fb:  LD      BC,(2D1CH)
        LD      HL,DATABUF
        INIR    
        LD      HL,(2DF3H)
        LD      DE,0100H
        OR      A
        SBC     HL,DE
        LD      (2DF3H),HL
        LD      B,10H
        LD      HL,DATABUF
        JP      DUMPHEX
l1718:  LD      A,01H
        LD      (2DF2H),A
        CALL    L1191
        XOR     A
        LD      (2DF2H),A
        LD      HL,1000H
        LD      (2DF3H),HL
        RET     

DSCMD:  CALL    L0194
        JR      C,L1759                 ; (+29h)
        LD      B,(IY+DSECPT)
l1733:  PUSH    BC
        CALL    L0148
        POP     BC
        JR      C,L1759                 ; (+1fh)
        LD      A,(2004H)
        OR      A
        JR      Z,L1747                 ; (+07h)
        DJNZ    L1733                   ; (-0fh)
        LD      A,03H
        SCF     
        JR      L1759                   ; (+12h)
l1747:  CALL    L0148
        JR      C,L1759                 ; (+0dh)
        LD      A,(2004H)
        CP      09H
        JR      Z,L1755                 ; (+02h)
        LD      A,05H
l1755:  LD      (2DF5H),A
        XOR     A
l1759:  RET     

        NOP     
        LD      C,1CH
        DEC     BC
        ADD     HL,DE
        EX      AF,AF'
        LD      D,1BH
        LD      A,(BC)
        JR      L176C                   ; (+07h)
        DEC     D
        INC     B
        ADD     HL,BC
        RLA     
        LD      B,14H
        INC     BC
l176c:  LD      DE,051FH
        INC     DE
        LD      (BC),A
        DJNZ    1791H   ; fixme                   ; (+1eh)
        DEC     C
        LD      (DE),A
        LD      BC,1D0FH
        INC     C
        LD      A,(DE)

L177A:  XOR     A
        LD      (2D1AH),A
        LD      (2D1BH),A
        LD      (L2D25),A
        LD      (2D24H),A
        LD      (2D35H),A
        CALL    L0604
        JR      C,L17FC                 ; (+6dh)
        LD      A,(IY+DHEADS)
        CP      0FH
        JR      Z,L17FC                 ; (+66h)
        LD      HL,0040H
        CALL    L188A
        LD      DE,(2D30H)
        LD      L,(IY+DMTRKLO)
        LD      H,(IY+DMTRKHI)
        OR      A
        SBC     HL,DE
        LD      A,01H
        JR      C,L17FC                 ; (+4fh)
        LD      A,(2D27H)
        OR      A
        JR      Z,L17C9                 ; (+16h)
        DEC     A
        CALL    NZ,RWCMD
        JR      C,L17FC                 ; (+43h)
        CALL    DODSC
        JR      C,L17FC                 ; (+3eh)
        CALL    WTCMD
        JR      C,L17FC                 ; (+39h)
        XOR     A
        LD      (2D35H),A
        JR      L17FC                   ; (+33h)
l17c9:  CALL    L1191
        LD      A,(2025H)
        LD      (2DF5H),A
        JR      C,L17FC                 ; (+28h)
        LD      HL,0040H
        CALL    L188A
        LD      HL,0040H
        ADD     HL,DE
        LD      (2D32H),HL
        LD      A,(2022H)
        CP      (IY+DHEADS)
        JR      Z,L17FB                 ; (+12h)
        ADD     A,A
        LD      (2D35H),A
        CALL    L1899
        LD      HL,0040H
        ADD     HL,DE
        LD      (2D32H),HL
        XOR     A
        LD      (2D34H),A
l17fb:  XOR     A
l17fc:  PUSH    AF
        LD      A,0FFH
        LD      (2D1AH),A
        POP     AF
        RET     

L1804:  CALL    L18AA
        RET     C

        LD      HL,(2D1EH)
        CALL    L188A
        LD      HL,(2D1EH)
        ADD     HL,DE
        LD      (2D32H),HL
        LD      C,H
        LD      B,L
        INC     C
l1818:  PUSH    BC
        CALL    WTCMD
        POP     BC
        JR      NZ,L1824                ; (+05h)
        DJNZ    L1818                   ; (-09h)
        DEC     C
        JR      NZ,L1818                ; (-0ch)
l1824:  PUSH    AF
        LD      A,0FFH
        LD      (2D1AH),A
        LD      A,01H
        LD      (2D05H),A
        POP     AF
        RET     

L1831:  CALL    L18AA
        RET     C

        LD      HL,(2D32H)
        LD      C,H
        LD      B,L
        INC     C
l183b:  PUSH    BC
        CALL    L1191
        POP     BC
        JR      NZ,L184D                ; (+0bh)
        DJNZ    L183B                   ; (-09h)
        DEC     C
        JR      NZ,L183B                ; (-0ch)
        XOR     A
        LD      HL,0040H
        JR      L1878                   ; (+2bh)
l184d:  PUSH    AF
        DEC     C
        LD      E,B
        LD      D,C
        LD      HL,(2D32H)
        OR      A
        SBC     HL,DE
        PUSH    HL
        LD      A,(2D35H)
        OR      A
        JR      NZ,L1861                ; (+03h)
        LD      A,(IY+DHEADS)
l1861:  ADD     A,A
        INC     A
        LD      E,A
        LD      D,00H
        LD      A,0FFH
l1868:  INC     A
        OR      A
        SBC     HL,DE
        JR      Z,L1870                 ; (+02h)
        JR      NC,L1868                ; (-08h)
l1870:  POP     HL
        LD      E,A
        LD      D,00H
        OR      A
        SBC     HL,DE
        POP     AF
l1878:  LD      (DATABUF),HL
        OUT     (00H),A
        PUSH    AF
        LD      A,0FFH
        LD      (2D1AH),A
        LD      A,01H
        LD      (2D05H),A
        POP     AF
        RET     

l188a:  LD      A,(IY+DHEADS)
        ADD     A,A
        CALL    L1899
        LD      HL,(2D22H)
        ADD     HL,DE
        LD      (2D30H),HL
        RET     

l1899:  LD      E,A
        LD      D,00H
        LD      A,0FFH
l189e:  INC     A
        OR      A
        SBC     HL,DE
        JR      Z,L18A6                 ; (+02h)
        JR      NC,L189E                ; (-08h)
l18a6:  LD      E,A
        LD      D,00H
        RET     

l18aa:  XOR     A
        LD      (2D1AH),A
        LD      (2300H),A
        LD      (2600H),A
        LD      (L2D25),A
        LD      (2D24H),A
        LD      (2D34H),A
        LD      HL,0000
        LD      (DATABUF),HL
        OUT     (00H),A
        CALL    L0604
        JR      C,L18EC                 ; (+22h)
        LD      A,(IY+DHEADS)
        CP      0FH
        JR      Z,L18EC                 ; (+1bh)
        LD      (IY+0BH),00H
        CALL    L0194
        JR      C,L18EC                 ; (+12h)
        LD      DE,(2D26H)
        LD      (2D1EH),DE
        LD      A,10H
        LD      (2D26H),A
        LD      (2D94H),A
        XOR     A
        RET     

l18ec:  PUSH    AF
        LD      A,0FFH
        LD      (2D1AH),A
        POP     AF
        SCF     
        RET     

L18F5:  OUT     (00H),A
        CALL    L120E
        LD      (DATABUF),A
        XOR     A
        RET     

L18FF:  DI
        LD      A,10H
        OUT     (08H),A
        EI      
        XOR     A
        LD      (L2D01),A

l1909:  LD      HL, SIGNON
        CALL    OUTSTR
        CALL    CRLFST
l1912:  CALL    GETCHAR
        JR      Z,L1912                 ; (-05h)
        LD      DE,190FH
        PUSH    DE
        LD      H,A
        CALL    L1E6B
        LD      L,A
        PUSH    HL
        LD      B,25H
        LD      HL,1C33H
l1926:  LD      D,(HL)
        INC     HL
        LD      E,(HL)
        INC     HL
        EX      (SP),HL
        PUSH    HL
        XOR     A
        SBC     HL,DE
        POP     HL
        JR      NZ,L1938                ; (+06h)
        POP     HL
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        PUSH    DE
        RET     

l1938:  EX      (SP),HL
        INC     HL
        INC     HL
        DJNZ    L1926                   ; (-17h)
        POP     HL
        LD      HL,INVSTR
        JP      OUTMSG

SIGNON: DB      27h                     ; L 1944 String length:
L1945:  DB      0Dh, 0Ah, 'IBC DIAGNOSTICS - DISK SLAVE V4.0 ', 0Dh, 0Ah, 0Ah

XTCMD:  LD      SP,3000H
        JP      L03F5

INCMD:  CALL    GETBYTE
        LD      C,A
        IN      A,(C)
        CALL    L19CF
        RET     

CICMD:  CALL    GETBYTE
        LD      C,A
l1980:  IN      A,(C)
        CALL    GETCHAR
l1985:  JR      L1980                   ; (-07h)

OUCMD:  CALL    GETBYTE
        LD      C,A
        CALL    GETBYTE
        OUT     (C),A
l1990:  RET     

COCMD:  CALL    OUCMD
        LD      B,A
l1995:  CALL    GETCHAR
        OUT     (C),B
        JR      L1995                   ; (-07h)

FBCMD:  CALL    PRSPACE
        CALL    GETWORD                 ; Fill address
        PUSH    HL
        CALL    PRSPACE
        POP     HL
        CALL    GETBYTE                 ; Fill data
        LD      (HL),A
        LD      D,H
        LD      E,L
        INC     DE
        LD      BC,00FFH
        LDIR                            ; Fill 256 byte of data at address.
        RET     

FICMD:  CALL    PRSPACE                 ; L 19B4
        CALL    GETWORD
        LD      BC,0100H
        XOR     A
l19be:  LD      (HL),A
        INC     A
        INC     HL
        DEC     C
        JR      NZ,L19BE                ; (-06h)
        DEC     B
        JR      NZ,L19BE                ; (-09h)
        RET     

; Read two Hex bytes
GETBYTE:
        CALL    PRSPACE
        CALL    L1E4A
        RET     

l19cf:  CALL    PRSPACE
        CALL    L1EEC
        RET     

; Unit Select
USCMD:  CALL    GETBYTE
        CP      00H                     ; Make sure unit is between 0
        JP      C,OUTMSG
        CP      04H                     ; ... and 3, otherwise error out.
        JP      NC,OUTMSG
        LD      (L2D21),A               ; Store the unit number in L2D21
        CALL    L069B
        RET     

RDCMD:  CALL    GETBYTE
        LD      (L2D25),A
        CALL    PRSPACE
        CALL    GETWORD
        LD      (2D22H),HL
        CALL    GETBYTE
        LD      B,A
        CALL    RDSECT
        LD      HL,DATABUF
        LD      B,14H
        JP      C,L1B32
        JP      DUMPHEX

WRCMD:  CALL    GETBYTE
        LD      (L2D25),A               ; Store head
        CALL    PRSPACE
        CALL    GETWORD
        LD      (2D22H),HL              ; Store track
        CALL    GETBYTE                 ; Get byte
        LD      B,A                     ; ... into B
        PUSH    BC
        CALL    GETBYTE                 ; Get byte
        POP     BC
        LD      C,A                     ; ... into C
        CALL    WRSECT
        JP      C,DERRMSG
        LD      B,14H
        LD      HL,DATABUF              ; Sector data at 2000 H
        JP      DUMPHEX
        RET     

WICMD:  CALL    GETBYTE                 ; L 1A33
        LD      (L2D25),A
        CALL    PRSPACE
        CALL    GETWORD
        LD      (2D22H),HL
        CALL    GETBYTE
        LD      B,A
        CALL    L0087
        JP      C,DERRMSG
        LD      B,14H
        LD      HL,DATABUF
        JP      DUMPHEX
l1a54:  CALL    L00A5
        CALL    GETCHAR
        JR      L1A54                   ; (-08h)

SLCMD:  CALL    L0043                   ; L 1a5c
        CALL    GETCHAR
        JR      SLCMD                   ; (-08h)

SCCMD:  CALL    GETBYTE                 ; L 1A64
        CP      00H                     ; Make sure drive number is between 0 and 3.
        LD      HL,INVSTR
        JP      C,OUTSTR
        CP      04H
        JP      NC,OUTSTR
        PUSH    IY
        OR      A
        JR      Z,L1A81                 ; Drive 0, no need to index, IY contains pointer to parameter table
        LD      DE,0040H
        LD      B,A
l1a7d:  ADD     IY,DE                   ; Index into drive parameter table? 64 bytes per HDD.
        DJNZ    L1A7D

l1a81:  LD      A,(IY+DONLINE)
        INC     A
        JP      Z,DOFFLINE              ; Drive is offline.
        CALL    CRLFST
        LD      HL,HEADMSG
        CALL    OUTSTR
        CALL    GETBYTE                 ; Number of heads.
        LD      (IY+DHEADS),A
        CALL    CRLFST
        LD      HL,L1DA1
        CALL    OUTSTR
        CALL    GETWORD                 ; Number of tracks.
        LD      (IY+DMTRKHI),H
        LD      (IY+DMTRKLO),L
        CALL    CRLFST
        LD      HL, WPCMSG
        CALL    OUTSTR
        CALL    GETWORD                 ; Write precompensation track
        LD      (IY+DWPCLO),L
        LD      (IY+DWPCHI),H
        LD      (IY+14H),00H
        LD      (IY+15H),01H
        LD      (IY+00H),0FFH
        LD      (IY+DCTRKLO),0FFH
        LD      (IY+DCTRKHI),0FFH
        LD      (IY+03H),0FFH
        LD      (IY+07H),0FFH
        LD      (IY+08H),0FFH
        LD      (IY+0DH),0FFH
        LD      (IY+DSECPT),20H         ; Sectors per track
        JR      L1AEB                   ; (+06h)

DOFFLINE:
        LD      HL,DNOTOL               ; 'drive not on line '
        CALL    OUTSTR

l1aeb:  POP     IY
        RET     

F0CMD:  CALL    L00F7                   ; l 1aee
        CALL    GETCHAR
        JR      F0CMD                   ; (-08h)

FMCMD:  CALL    GETBYTE                 ; L 1AF6
        LD      (L2D25),A
        CALL    FMTHEAD
        JP      C,DERRMSG
        RET     

NECMD:  XOR     A
        LD      (L2D18),A
        RET     

IDCMD:  CALL    GETBYTE
        LD      (L2D25),A
        CALL    PRSPACE
        CALL    GETWORD
        LD      (2D22H),HL
        CALL    L013A
        JR      C,DERRMSG                 ; (+0fh)
        LD      HL,DATABUF
        LD      B,02H
        JR      DUMPHEX                   ; (+22h)

CACMD:  CALL    L011D
        CALL    GETCHAR
        JR      CACMD                   ; (-08h)

DERRMSG:  LD    HL,DERRSTR
        CALL    OUTSTR
        RET     

l1b32:  CP      0AH
        JR      NZ,DERRMSG                ; (-0bh)
        CALL    CRLFST
        LD      HL,1CF2H
        CALL    OUTSTR
        RET     

DMCMD:  CALL    GETWORD
        LD      B,10H
DUMPHEX:
        PUSH    BC
        PUSH    HL
        CALL    CRLFST
        POP     HL
        CALL    L1EE7
        CALL    L1F2D
        LD      B,10H
        PUSH    HL
l1b54:  LD      A,(HL)
        CALL    L1EEC
        INC     HL
        DJNZ    L1B54                   ; (-07h)
        CALL    L1F2D
        POP     HL
        LD      B,10H
l1b61:  LD      A,(HL)
        CALL    L1EFF
        INC     HL
        DJNZ    L1B61                   ; (-07h)
        POP     BC
        DJNZ    DUMPHEX                   ; (-26h)
        RET     

SMCMD:  CALL    PRSPACE
        CALL    GETWORD
l1b72:  LD      A,(HL)
        CALL    L19CF
        CALL    PRSPACE
        CALL    L1E6B
        CP      20H
        JR      Z,L1B8E                 ; (+0eh)
        LD      B,00H
        PUSH    HL
        LD      HL,1B8AH
        EX      (SP),HL
        CALL    L1E58
        CALL    L1E4D
        LD      (HL),A
l1b8e:  INC     HL
        PUSH    HL
        CALL    CRLFST
        POP     HL
        CALL    L1EE7
        JR      L1B72                   ; (-27h)

QCCMD:  CALL    GETBYTE                 ; 0-3 (Drive number?)
        CP      00H
        JP      C,OUTMSG
        CP      04H
        JP      NC,OUTMSG
        PUSH    AF
        CALL    GETBYTE
        CP      00H
        JP      C,OUTMSG
        CP      0DH                     ; 0-12
        JP      NC,OUTMSG
        LD      B,A
        POP     AF                      ; First parameter in A, second in B
        LD      E,A                     ; Drive number in E
        LD      D,00H                   ; DE = 000n where N is the drive number
        LD      HL,L09B9                ; Drive number to state information mapping table
        ADD     HL,DE
        ADD     HL,DE
        LD      E,(HL)
        INC     HL
        LD      D,(HL)                  ; Point DE to 2C00, 2c40, 2c80, 2cc0 depending on drive selected.
        LD      HL,L09CC
        PUSH    BC
        LD      BC,14                   ; Copy 14 bytes from 09CC to 2C00
        LDIR    
        POP     BC
        LD      HL,L038E
        LD      A,B
        OR      A
        JR      Z,L1BDA                 ; (+08h)
        PUSH    DE
        LD      DE,0008H
l1bd6:  ADD     HL,DE
        DJNZ    L1BD6                   ; (-03h)
        POP     DE
l1bda:  LD      BC,0008H
        LDIR    
        RET     

l1be0:  PUSH    AF
        INC     DE
        CALL    L1BF2
        POP     AF
        OR      A
        RRCA    
        RRCA    
        RRCA    
        RRCA    
        CALL    L1BF2
        INC     DE
        INC     DE
        INC     DE
        RET     

l1bf2:  AND     0FH
        CP      0AH
        JR      NC,L1BFD                ; (+05h)
        ADD     A,30H
        LD      (DE),A
        DEC     DE
        RET     

l1bfd:  SUB     0AH
        ADD     A,41H
        LD      (DE),A
        DEC     DE
        RET     

BUCMD:  CALL    L1C18
        CALL    L12F1
        CALL    C,L19CF
        RET     

RSCMD:  CALL    L1C18
        CALL    L1316
        CALL    C,L19CF
        RET     

l1c18:  CALL    GETBYTE
        LD      (L2D21),A
        CALL    PRSPACE
        CALL    GETWORD
        LD      (2D22H),HL
        CALL    PRSPACE
        CALL    GETWORD
        LD      (2D26H),HL
        RET     

; Pointer to command jump table.
L1C31:  DW      L1C33

; Diagnostic Monitor Command Jump Table:
L1C33:  DB      'IN'
        DW      INCMD
        DB      'CI'
        DW      CICMD
        DB      'OU'
        DW      OUCMD
        DB      'CO'
        DW      COCMD
        DB      'FB'
        DW      FBCMD
        DB      'FI'
        DW      FICMD
        DB      'WI'
        DW      WICMD
        DB      'DM'
        DW      DMCMD
        DB      'SM'
        DW      SMCMD
        DB      'RD'
        DW      RDCMD
        DB      'WR'
        DW      WRCMD
        DB      'HM'
        DW      HMCMD
        DB      'SL'
        DW      SLCMD
        DB      'F0'
        DW      F0CMD
        DB      'FM'
        DW      FMCMD
        DB      'ID'
        DW      IDCMD
        DB      'CA'
        DW      CACMD
        DB      'SC'
        DW      SCCMD
        DB      'BU'
        DW      BUCMD
        DB      'RS'
        DW      RSCMD
        DB      'GL'
        DW      GLCMD
        DB      'DU'
        DW      DUCMD
        DB      'RT'
        DW      RTCMD
        DB      'WT'
        DW      WTCMD
        DB      'RW'
        DW      RWCMD
        DB      'US'
        DW      USCMD
        DB      'QC'
        DW      QCCMD
        DB      'DS'
        DW      DSCMD
        DB      'TM'
        DW      TMCMD
        DB      'NE'
        DW      NECMD
        DB      'XT'
        DW      XTCMD
        DB      'SV'
        DW      SVCMD



INVSTR: DB      06h                     ; L1CB3
        DB      ' - inv'
DERRSTR:DB      0Bh                     ; L1CBA
        DB      ' - disk err'
L1CC6:  DB      0Ah
        DB      ' - cmp err'
        DB      20h
L1CD2:  DB      10h
        DB      ' - restore/seek error'
L1CE8:  DB      09h
        DB      ' - rd err'
L1CF2:  DB      0Ah
        DB      ' - ECC err'
L1CFD:  DB      11h
        DB      ' - soft ECC error'
L1D0F:  DB      1Bh
        DB      ' - irrecoverable error'
L1D26:  DB      0Ch
        DB      ' - bad data'
L1D32:  DB      0Eh
        DB      ' - write error'
L1D41:  DB      0Eh
        DB      ' byte '
L1D48:  DB      0, 0
        DB      ' is '
L1D4E:  DB      0, 0
L1D50:  DB      27H
        DB      'Head '
L1D56:  DB      0, 0
        DB      ' Track '
L1D5F:  DB      0, 0, 0, 0
        DB      ' Sector '
L1D6B:  DB      0, 0
        DB      ' Pattern '
L1D76:  DB      0, 0
L1D78:  DB      06h
        DB      'ATUS -'
L1D7F:  DB      08h
        DB      ' PARAM -'
HEADMSG:DB      17h                     ; L1D88:
        DB      'Enter max head number:  '
L1DA1:  DB      18h
        DB      'Enter max track number:  '
WPCMSG: DB      25h                             ; L1DBB
        DB      'Enter track to turn on write precom: '
DNOTOL: DB      12h                             ; L1DE1
        DB      'drive not on line '

L1DF4:  DB      21h
L1DF5:  DB      0, 0


l1df7:  LD      A,(DE)
        INC     DE
        OR      A
        RET     Z

        SUB     30H
l1dfd:  RET     C

        CP      0AH
        CCF     
        RET     C

        PUSH    DE
        LD      D,00H
        LD      E,A
        PUSH    DE
l1e07:  ADD     HL,HL
        LD      D,H
        LD      E,L
        ADD     HL,HL
        ADD     HL,HL
        ADD     HL,DE
        POP     DE
        ADD     HL,DE
        POP     DE
        RET     C

        JR      L1DF7                   ; (-1ch)
        PUSH    BC
        PUSH    DE
        LD      B,A
l1e16:  LD      DE,0010H
l1e19:  ADD     HL,HL
        LD      A,D
        RLA     
        CP      B
        JR      C,L1E21                 ; (+02h)
        SUB     B
        INC     L
l1e21:  LD      D,A
        DEC     E
        JR      NZ,L1E19                ; (-0ch)
        POP     DE
        POP     BC
        RET     

        CALL    PRSPACE
l1e2b:  CALL    L1E6B
        CP      0DH
        JR      Z,L1E3E                 ; (+0ch)
        CP      08H
        JR      NZ,L1E3A                ; (+04h)
        INC     B
l1e37:  DEC     HL
        JR      L1E2B                   ; (-0fh)
l1e3a:  LD      (HL),A
        INC     HL
        DJNZ    L1E2B                   ; (-13h)
l1e3e:  XOR     A
        LD      (HL),A
l1e40:  RET     

; Read 16 bits from Console into HL
GETWORD:  CALL    L1E4A
        LD      H,A
        CALL    L1E4A
        LD      L,A
        RET     

l1e4a:  CALL    L1E51
l1e4d:  RLA     
        RLA     
        RLA     
        RLA     
l1e51:  PUSH    BC
        AND     0F0H
        LD      B,A
        CALL    L1E6B
l1e58:  SUB     30H
        JR      C,INVMSG                 ; (+4ch)
l1e5c:  CP      0AH
        JR      C,L1E68                 ; (+08h)
        SUB     07H
        JR      C,INVMSG                 ; (+44h)
        CP      10H
        JR      NC,INVMSG                ; (+40h)
l1e68:  OR      B
        POP     BC
        RET     

l1e6b:  CALL    L1E74
        JR      Z,L1E6B                 ; (-05h)
        CALL    GETCHAR
        RET     

l1e74:  LD      A,0CH
        PUSH    BC
        LD      C,A
        IN      A,(C)
        BIT     0,A
        POP     BC
        RET     

; GETCHAR - Read character from Console, return to Monitor if ESC.
GETCHAR: PUSH    BC
        CALL    L1E74                   ; L 1E7E
        JR      Z,L1EA6                 ; (+22h)
        IN      A,(0DH)
        LD      B,A
        LD      A,30H
        OUT     (08H),A
l1e8b:  IN      A,(0CH)
        BIT     0,A
        JR      NZ,L1E8B                ; (-06h)
        LD      A,10H
        OUT     (08H),A
        LD      A,B
        AND     7FH
        CP      'a'                     ; > 'a'
        JR      C,L1E9E                 ; (+02h)
        RES     5,A                     ; Convert to lower case.
l1e9e:  CP      1BH                     ; ESC?
        JP      Z,L1EAE                 ; Signon and back to the * prompt.
        CALL    PUTC
l1ea6:  POP     BC
        RET     

; Print "- inv" message
INVMSG: LD      HL,INVSTR               ; L 1EA8
OUTMSG: CALL    OUTSTR                  ; L 1EAB

l1eae:  LD      SP,3000H
        JP      L1909
l1eb4:  LD      DE,L1F38
        LD      IY,L1EBE
        JP      RESET
l1ebe:  IN      A,(00H)                 ; SIO Status Port
        AND     01H
        JR      Z,L1EBE                 ; (-06h)
        IN      A,(01H)                 ; SIO Data Port
        AND     5FH
        CP      1BH
        JP      Z,RESET
        CP      'M'
        JP      Z,RESET
        JR      L1EB4                   ; (-20h)
        LD      HL, CRSTR               ; 1F5FH
        JR      OUTSTR                  ; (+03h)
CRLFST: LD      HL,L1F5B                ; l 1ed9: Prints <CR>,<LF>,*

OUTSTR: PUSH    BC                      ; L 1edc
        LD      B,(HL)
l1ede:  INC     HL
        LD      A,(HL)
        CALL    PUTC                    ; L 1F09 Output character
        DJNZ    L1EDE                   ; (-07h)
        POP     BC
        RET     

l1ee7:  LD      A,H
        CALL    L1EEC
        LD      A,L
l1eec:  PUSH    AF
        RRA     
        RRA     
        RRA     
        RRA     
        CALL    L1EF5
        POP     AF
l1ef5:  AND     0FH
        ADD     A,30H
        CP      3AH
        JR      C,L1EFF                 ; (+02h)
        ADD     A,07H
l1eff:  CP      20H
        JR      C,L1F07                 ; (+04h)
        CP      80H
        JR      C,PUTC                 ; (+02h)
l1f07:  LD      A,2EH

; Send character in A to host.
; Reads port 0Ch to determine if host is ready, then
; outputs lower nibble to port 08h, checks host ready again, and
; outputs high nibble to 08h, with bit 4 set.
PUTC:PUSH    BC
        LD      B,A
        LD      A,0CH
        LD      C,A
l1f0e:  IN      A,(C)
        BIT     1,A
        JR      Z,L1F0E                 ; (-06h)
        LD      A,B
        AND     0FH
        OUT     (08H),A
l1f19:  IN      A,(C)
        BIT     2,A
        JR      Z,L1F19                 ; (-06h)
        LD      A,B
        RRA     
        RRA     
        RRA     
        RRA     
        AND     0FH
        SET     4,A
        OUT     (08H),A
        LD      A,B
        POP     BC
        RET     

l1f2d:  CALL    PRSPACE

PRSPACE:PUSH    AF
        LD      A, ' '
        CALL    PUTC
        POP     AF
        RET     

L1F38:  DB      'Memory Parity Error!!! (ESC or M)', 07h, 00h
L1F5B:  DB      03h
        DB      0Dh, 0Ah, '*'

CRSTR:  DB      01h                     ; L1F5F
        DB      0Dh
