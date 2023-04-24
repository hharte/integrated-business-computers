; IBC/Integrated Business Computers
; IBC Loader PROM - SUPER-CADET  V1.1
;
; Partially commented disassembly of IBC_DMP047_REV_A.bin
; The PROM is a 2764 (8K*8) EPROM.
;
; Assemble with the zmac assembler: http://48k.ca/zmac.html
;
; The Loader PROM supports the following disk controllers:
;     WD1795 with external FIFO, interrupt driven (8" or 5.25".)
;     IBC SMD Hard Disk Controller.
;
;NUL        EQU     00H
CR      EQU     0DH
LF      EQU     0AH
ESC     EQU     1BH

SPT5    EQU     16                      ; 16 sectors per track for 5.25" drives.
SPT8SD  EQU     13                      ; 13 sectors per track for 8" single-density drives.
SPT8DD  EQU     26                      ; 26 sectors per track for 8" double-density drives.

DISKBUF EQU     08000H                  ; Disk buffer
DBSIZE  EQU     01A00H                  ; Disk buffer size: 26*256-byte sectors

ROMDSB  EQU     0BFFEH                  ; Contains the instruction to disable the ROM.
BOOTSTP EQU     0C000H                  ; Disk bootstrap is copied into memory here.

RAMUTL  EQU     0E100H                  ; Floppy / Hard Disk Utilities copied to RAM at 0E100H
LE102   EQU     0E102H
FDCVEC  EQU     0E104H                  ; Floppy Disk Interrupt Vector
LE106   EQU     0E106H
DISKRD  EQU     0E108H                  ; Read from disk, either floppy or hard.

FDCPARAM EQU    0E400H                  ; FDC PARAM
FDCSTATUS EQU   0E401H                  ; FDC STATUS
LE402   EQU     0E402H
FDUNIT  EQU     0E415H                  ; Selected FDC Unit
LE416   EQU     0E416H
SIOBASE EQU     0E41AH                  ; Console Status Port
LE41C   EQU     0E41CH
LE41D   EQU     0E41DH
FDHEAD  EQU     0E420H                  ; Floppy disk head
BFNAME  EQU     0E422H                  ; Boot Filename (17 bytes)
LE434   EQU     0E434H                  ; Used by hard disk boot

; HDC Task File
TF_CMD  EQU     0E440H                  ; HDC Command (Bit 7 is always set to indicate this is the first block of registers)
TF_SA5  EQU     0E441H                  ; SA5: 0 or 3 into E441 depending on DIP Switch. 0 in our case.
TF_TRKL EQU     0E442H                  ; Track Low, passed in DE registers when calling into bootstrap
;LE443   EQU     0E443H                 ; Track High
LE444   EQU     0E444H                  ; Current sector
LE445   EQU     0E445H                  ; Current Head, passed in B register when calling into botostrap
LE446   EQU     0E446H                  ; Sector Count
;LE447   EQU     0E447H                 ; SA3 (Unused?)

REMSEC  EQU     0E448H                  ; Remaining sectors to read
LE449   EQU     0E449H                  ; Used by Floppy bootstrap

LE500   EQU     0E500H
LE501   EQU     0E501H                  ; SMD Controller ARG1
LE502   EQU     0E502H                  ; SMD Controller ARG0
LE503   EQU     0E503H
LE504   EQU     0E504H
LE505   EQU     0E505H                  ; Used by Hard and Floppy bootstrap
LE506   EQU     0E506H
LE520   EQU     0E520H                  ; First 32 bytes of the second sector of the boostrap (boot arguments?)
TOTSEC  EQU     0E539H                  ; Total number of sectors to read
LE53B   EQU     0E53BH                  ; Used by Floppy bootstrap

STKTOP  EQU     0FFFEH                  ; Stack

; I/O Ports
SIO0S   EQU     000H                    ; 8650 ACIA Status Port
SIO0D   EQU     001H                    ; 8650 ACIA Data Port
TIMER   EQU     014H                    ; Interval timer
FDCSTAT EQU     024H                    ; WD1795 FDC Status Register (Read)
FDCCMD  EQU     024H                    ; WD1795 FDC Command Register (Write)
FDCTRK  EQU     025H                    ; WD1795 FDC Track Register
FDCSEC  EQU     026H                    ; WD1795 FDC Sector Register
FDCDATA EQU     027H                    ; WD1795 FDC Data Register
FDCFIFO EQU     028H                    ; IBC MCC Floppy Data FIFO

SMDERR  EQU     040H                    ; IBC SMD Error Register
SMDARG0 EQU     040H                    ; IBC SMD Argument 0 Register
SMDARG1 EQU     041H                    ; IBC SMD Argument 0 Register
SMDCMD  EQU     042H                    ; IBC SMD Command Register
SMDSEC  EQU     043H                    ; IBC SMD Sector Register
SMDDATA EQU     044H                    ; IBC SMD Data FIFO
SMDSTAT EQU     047H                    ; IBC SMD Status Register
SMDSCID EQU     047H                    ; IBC SMD Sector ID

DIPSW   EQU     03CH                    ; IBC MCC DIP Switch at location E.
BAUDRT  EQU     03DH                    ; Super-Cadet baud rate register

; DIP Switch Bits:
SW_ROMMON       EQU     00H             ; Enter ROM monitor if ON, auto boot if OFF.
SW_HDBOOT       EQU     01H             ; Boot Hard Disk if ON, boot Floppy if OFF.
SW_MEMTEST      EQU     02H             ; Run RAM test if ON.
SW_HDSEL        EQU     05H             ; OFF = Boot hard disk 0, ON = Boot Hard Disk 3?
SW_FDCTYPE      EQU     06H             ; Floppy Disk Type: OFF = 8-inch, ON = 5.25-inch.
SW_PORT20H      EQU     07H


HDCSTAT EQU     040H                    ; Hard Disk Status Register (Read)
HDCCMD  EQU     040H                    ; Hard Disk Command Register (Write)

ACIA_MR EQU     03H                     ; MC6850 ACIA Master Reset
ACIA_16 EQU     01H                     ; ACIA baud rate divide by 16.
ACIA_82 EQU     10H                     ; ACIA 8 bits + 2 stop bits.

        ORG 0
START:  DI
        XOR     A
        OUT     (62H),A
        IN      A,(TIMER)
        IN      A,(FDCSTAT)
        IN      A,(80H)
        XOR     A
        OUT     (SMDARG0),A
        OUT     (SMDARG1),A
        LD      A,10H
        OUT     (SMDCMD),A
        OUT     (SMDSCID),A
        JR      INIT

        ORG     0063H
        JP      0
NMIISR: JP      PARERR

; Unlock baud rate for SIO port by writing all
; baud rates from 0-7 with the SET bit clear.
; When the new rate matches the current rate,
; the baud rate will be unlocked, and can be
; set by writing the new baud rate with the SET
; bit set.
;
; +-----------------------------------------------+
; |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |
; | SET | A1  | A0  | B1  | B0  | A3  | A2  | B2  |
; +-----------------------------------------------+
INIT:   LD      D,16                    ; Loop through 16 ports
l006b:  XOR     A
        LD      E,A
        LD      C,08H
        LD      A,D
        DEC     A                       ; Port number to unlock.
        RRCA
        RRCA
        RRCA                            ; Move SIO portnum to bits A1-A0.
        AND     60H                     ; and isolate.
        LD      L,A
        LD      A,D
        DEC     A
        RRCA                            ; Move SIO portnum to A3-A2.
        AND     06H                     ; and isolate.
        OR      L                       ; Combine A3-A2, A1-A0
        LD      L,A
l007e:  LD      A,E
        LD      B,L
        OR      A
        JR      Z,L0096                 ; (+13h)
        CP      04H
        JR      C,L008F                 ; (+08h)
        SET     0,L
        SUB     04H
        LD      E,A
        LD      B,L
        JR      Z,L0096                 ; (+07h)
l008f:  LD      B,A
        LD      A,L
l0091:  ADD     A,08H
        DJNZ    L0091                   ; (-04h)
        LD      B,A
l0096:  LD      A,B
        OUT     (BAUDRT),A              ; Write to the baud rate port
        INC     E
        DEC     C
        JR      NZ,L007E                ; (-1fh)
        DEC     D
        JR      NZ,L006B                ; (-35h)
        OUT     (50H),A

; Set baud rate for all ports to 9600
        LD      E,89H                   ; Baud SET bit, 9600 baud.
        LD      B,16                    ; Loop through 16 ports
l00a6:  LD      A,B
        DEC     A
        RRCA
        RRCA
        RRCA
        AND     60H
        LD      L,A
        LD      A,B
        DEC     A
        RRCA
        AND     06H
        OR      L
        OR      E
        OUT     (BAUDRT),A              ; Write to the baud rate port
        DJNZ    L00A6                   ; (-13h)

; Unlock the console port baud rate again by rewriting the current baud setting.
        RES     7,A                     ; Clear baud SET bit
        OUT     (BAUDRT),A              ; Unlock SIO port 0.

; Set SIO baud rate according to DIP switches
        LD      L,00H
        IN      A,(DIPSW)				; DIP SW 4-6
        AND     38H
        RRCA
        RRCA
        RRCA
        AND     07H
        JR      Z,L00DB                 ; SW 4-6 = 0: 300 baud
        CP      04H
        JR      C,L00D4                 ; (+06h)
        SET     0,L
        SUB     04H
        JR      Z,L00DB                 ; (+07h)
l00d4:  LD      B,A
        LD      A,L
l00d6:  ADD     A,08H
        DJNZ    L00D6                   ; (-04h)
        LD      L,A
l00db:  LD      A,L
        SET     7,A                     ; Baud SET bit
        OUT     (BAUDRT),A              ; Set console port baud rate

; Initialize Serial Ports
        LD      B,16
        LD      HL,SIOTAB
SIOLP:  LD      C,(HL)
        INC     HL
        LD      A,ACIA_MR
        OUT     (C),A
        LD      A,ACIA_16 OR ACIA_82    ; Divide by 16, 8 data bits, 2 stop bits.
        OUT     (C),A
        INC     C
        IN      D,(C)
        DJNZ    SIOLP

; Initialize DTR for each of the 16 ports.
        LD      B,08H
        XOR     A
DTRLP1: OUT     (1EH),A                 ; Clear DTR (ports 0-7)
        OUT     (1FH),A                 ; Clear DTR (ports 8-15)
        INC     A
        DJNZ    DTRLP1

        LD      B,08H
        XOR     A
DTRLP2: OUT     (1CH),A                 ; Set DTR (ports 0-7)
        OUT     (1DH),A                 ; Set DTR (ports 8-15)
        INC     A
        DJNZ    DTRLP2

        LD      SP,0
        IN      A,(DIPSW)
        AND     07H
        CP      04H
        JR      C,L014A                 ; < 4 Auto boot or ROM monitor
        AND     03H                     ; >= 4 Memory Test
        JR      Z,L0126                 ; (+0fh)
        LD      SP,00A0H
        DEC     A
        JR      Z,L0126                 ; (+09h)
        LD      SP,0140H
        DEC     A
        JR      Z,L0126                 ; (+03h)
        LD      SP,01E0H
l0126:  LD      B,00H
l0128:  LD      C,0C0H
        EXX
        LD      B,20H
        XOR     A
l012e:  EXX
        OUT     (C),A
        SET     5,C
        OUT     (C),A
        RES     5,C
        INC     C
        EXX
        DJNZ    L012E                   ; (-0dh)

        EXX
        LD      A,08H
        ADD     A,B
        LD      B,A
        JR      NC,L0128                ; (-1ah)
        LD      B,80H
        LD      C,0C0H
        LD      L,C
        LD      H,B
        JR      L019C                   ; (+52h)

l014a:  LD      HL,L01C1
        LD      DE,L01E1
        LD      B,00H
l0152:  LD      C,0C0H
        EXX
        LD      B,20H
l0157:  EXX
        LD      A,(HL)
        OUT     (C),A
        IN      A,(C)
L015D:  IN      A,(C)
        SET     5,C
        LD      A,(DE)
        OUT     (C),A
        IN      A,(C)
        IN      A,(C)
        RES     5,C
        INC     C
        EXX
        DJNZ    L0157                   ; (-17h)
        EXX
        INC     HL
        INC     DE
        LD      A,08H
        ADD     A,B
        LD      B,A
        JR      NC,L0152                ; (-25h)

        LD      SP,0020H
        LD      B,40H
        IN      A,(DIPSW)
        RRCA
        RRCA
        RRCA
        RRCA
        RRCA
        RRCA
        AND     03H
        JR      Z,L0194                 ; (+0ch)
        LD      B,0A0H
        DEC     A
        JR      Z,L0194                 ; (+07h)
        LD      B,48H
        DEC     A
        JR      Z,L0194                 ; (+02h)
        LD      B,50H
l0194:  LD      C,0C0H
        LD      L,C
        LD      H,B
l0198:  LD      C,L
        LD      B,H
        INC     C
        INC     L
l019c:  LD      IY,L01A3
        JP      L02AA

L01A3:  OUT     (C),A
        SET     5,C
        LD      IY,L01AE
        JP      L02A0

L01AE:  OUT     (C),A
        RES     5,C
        INC     SP
        LD      A,08H
        ADD     A,B
        LD      B,A
        JR      NC,L019C                ; (-1dh)
        INC     C
        LD      A,C
        CP      0E0H
        JR      NZ,L0198                ; (-27h)
        JR      L0218                   ; (+57h)

L01C1:  DB      01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H
        DB      01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H
        DB      01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H
        DB      01H, 01H, 01H, 01H, 01H, 01H, 01H, 01H
L01E1:  DB      00H, 02H, 04H, 06H, 08H, 0AH, 0CH, 0EH
        DB      10H, 12H, 14H, 16H, 18H, 1AH, 1CH, 1EH
        DB      20H, 22H, 24H, 26H, 28H, 2AH, 2CH, 2EH
        DB      30H, 32H, 34H, 36H, 38H, 3AH, 3CH, 3EH
        DB      40H, 42H, 44H, 46H, 48H, 4AH
SIOTAB:                                 ; SIO Port I/O address table
        DB      00H, 02H, 04H, 06H, 08H, 0AH, 0CH, 0EH
        DB      10H, 12H, 2CH, 2EH, 30H, 32H, 34H, 36H
        DB      0FFH

l0218:  XOR     A
        OUT     (38H),A
        IN      A,(DIPSW)
        AND     07H
        CP      04H
l0221:  JP      NC,MTCMD
; Zero all 64K of RAM
RAMCLR: LD      BC,0                    ; 0224H Clear RAM
        LD      HL,0
        XOR     A
ZEROLP: LD      (HL),A
        INC     HL
        DJNZ    ZEROLP
        DEC     C
        JR      NZ,ZEROLP
        LD      SP,STKTOP
        LD      A,0E1H
        LD      I,A                     ; Set IM2 vector to 0E1xx.
l0239:  LD      DE,FDUTILS
        LD      HL,FDUTILS8_END
        XOR     A
        OUT     (1CH),A
        SBC     HL,DE
        LD      C,L
        LD      B,H                     ; length of FDC utilities in BC
        LD      DE,RAMUTL
        LD      HL,FDUTILS
        LDIR                            ; Copy FDC utilities to RAM at E100H.
        LD      DE,RAMUTL
        LD      HL,(0E118H)
        ADD     HL,DE
        LD      (0E118H),HL
        IN      A,(FDCSTAT)
        IM      2
        EI
        LD      BC,0011H
        LD      DE,BFNAME
        LD      HL,NUCSTR
        LDIR
l0268:  IN      A,(DIPSW)
        AND     07H
        JR      Z,AUTOF                 ; Automatically boot floppy disk (SW1-3 ON)
        DEC     A
        JR      Z,L028B                 ; Diagnostics (SW1=OFF, SW2,3=ON)
        DEC     A
        JP      Z,BSCMD                 ; Automatically boot hard disk
        DEC     A
        JP      Z,SICMD3                ; Memory Test (Lower 512K) (FC)
        DEC     A
        JP      Z,MTCMD                 ; Memory Test (Upper 512K)
AUTOF:  LD      A,30H
        OUT     (2AH),A
        LD      (FDCPARAM),A
        IN      A,(FDCSTAT)
        BIT     7,A
        JP      Z,BFCMD

; Initialize serial ports to 38400,8,n,1
l028b:  LD      HL,SIOTAB
        LD      A,(HL)
        INC     HL
l0290:  LD      (SIOBASE),A
        CALL    GETCHAR
        JR      L0268                   ; (-30h)
        LD      A,(HL)
        INC     HL
        CP      0FFH
        JR      Z,L0268                 ; (-36h)
        JR      L0290                   ; (-10h)

l02a0:  EXX
        LD      HL,0
        ADD     HL,SP
        ADD     HL,HL
        LD      A,L
        EXX
        JP      (IY)

l02aa:  EXX
        LD      HL,0
        ADD     HL,SP
        LD      A,80H
        LD      IX,L02B8
        JP      L02C4
L02B8:  LD      B,L
        LD      IX,L02C0
        JP      L02D6
L02C0:  LD      A,L
        EXX
        JP      (IY)

l02c4:  LD      B,A
        LD      DE,0010H
l02c8:  ADD     HL,HL
        LD      A,D
        RLA
        CP      B
        JR      C,L02D0                 ; (+02h)
        SUB     B
        INC     L
l02d0:  LD      D,A
        DEC     E
        JR      NZ,L02C8                ; (-0ch)
        JP      (IX)
l02d6:  LD      HL,0001H
        LD      A,B
        OR      A
        JR      Z,L02E0                 ; (+03h)
l02dd:  ADD     HL,HL
        DJNZ    L02DD                   ; (-03h)
l02e0:  JP      (IX)

ROMMON: LD      HL,SIGNON       ; L02E2
        CALL    PRSTRN
L02E8:  CALL    PRPRMPT
l02eb:  CALL    GETCHAR
        JR      Z,L02EB                 ; (-05h)
        LD      DE,L02E8
        PUSH    DE
        LD      H,A
        CALL    WAITCHAR
        LD      L,A
        PUSH    HL
        LD      B,1AH
        LD      HL,090DH
l02ff:  LD      D,(HL)
        INC     HL
        LD      E,(HL)
        INC     HL
        EX      (SP),HL
        PUSH    HL
        XOR     A
        SBC     HL,DE
        POP     HL
        JR      NZ,L0311
        POP     HL
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        PUSH    DE
        RET

l0311:  EX      (SP),HL
        INC     HL
        INC     HL
        DJNZ    L02FF
        POP     HL
        LD      HL,INVSTR
        JP      MONIT

SIGNON  DB      SIGNON_LEN, CR, LF, 'IBC Loader PROM - SUPER-CADET  V1.1 ', CR, LF, LF
SIGNON_LEN EQU  $ - SIGNON - 1
NUCSTR: DB      'SYSTEM  NUCLEUS ', 0

BFCMD:  XOR     A
        OUT     (SMDARG0),A
        OUT     (SMDDATA),A
        LD      A,SPT8DD
l035f:  LD      (TOTSEC),A
        XOR     A
        LD      (FDUNIT),A
        LD      (LE53B),A
        CALL    LE102
        LD      B,00H
        LD      E,00H
        LD      HL,DISKBUF
        CALL    DISKRD
        JR      C,BFCMD                 ; (-20h)
        JP      BOOTSTRAP

; Floppy Utilities for 8" controller, copied to e100.
FDUTILS:
        XOR     A                       ; E100: Reset
        RET

        JR      L0395                   ; E192: HOME
        DW      FDCISR-FDUTILS+RAMUTL   ; E104: FDC ISR address.
        JR      L03A5                   ; E106:
        JR      FDREAD                  ; E108:
        JP      L06D0                   ; E10A:
        NOP
        NOP                             ; E10C
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        DB      5DH, 01H

L0395:  LD      A,01H
        LD      (LE41C),A
        RET

FDREAD: LD      D,8CH
        BIT     0,B
        JR      Z,L03AD                 ; (+0ch)
        SET     1,D
        JR      L03AD                   ; (+08h)
l03a5:  LD      D,0ACH
        BIT     0,B
        JR      Z,L03AD                 ; (+02h)
        SET     1,D
l03ad:  LD      C,00H
        PUSH    HL
        LD      HL,LE416
        LD      A,(FDUNIT)
        AND     03H
        ADD     A,L
        LD      L,A
        JR      NC,L03BD                ; (+01h)
        INC     H
l03bd:  EX      (SP),HL
        POP     IX
        LD      A,(FDUNIT)
        OR      38H
        BIT     5,D
        JR      Z,L03CB                 ; (+02h)
        RES     5,A
l03cb:  BIT     0,B
        JR      Z,L03D1                 ; (+02h)
        SET     2,A
l03d1:  LD      B,A
        LD      A,(TOTSEC)
        CP      0EH
        JR      C,L03E7                 ; (+0eh)
        XOR     A
        CP      E
        JR      NZ,L03EE                ; (+11h)
        LD      A,(LE53B)
        OR      A
        JR      Z,L03E7                 ; (+04h)
        BIT     2,B
        JR      NZ,L03EE                ; (+07h)
l03e7:  LD      A,B
        LD      B,80H
        RES     3,A
        JR      L03F1                   ; (+03h)
l03ee:  LD      A,B
        LD      B,00H
l03f1:  OUT     (2AH),A                 ; Write PARAM register
        LD      (FDCPARAM),A
        LD      A,B
        LD      (LE41D),A
l03fa:  IN      A,(FDCSTAT)             ; FDC Status Register
        BIT     0,A
        JR      NZ,L03FA                ; Wait for FDC not busy.
        BIT     7,A
        JR      NZ,L043F
        LD      A,(LE41C)
        RRA
        JR      NC,L041D
        LD      A,0CH                   ; Restore
        OUT     (FDCCMD),A              ; FDC Command
l040e:  JR      L040E
        BIT     7,A
        LD      A,52H
        JR      NZ,L043F
        XOR     A
        LD      (LE41C),A
        LD      (IX+00H),A
l041d:  LD      A,(IX+00H)
        OUT     (FDCTRK),A
        LD      A,0AH
l0424:  DEC     A
        JR      NZ,L0424
        IN      A,(FDCSTAT)             ; FDC Status Register
        BIT     7,A
        LD      A,73H
        JR      NZ,L043F
        LD      A,E
        LD      (IX+00H),A
        OUT     (FDCDATA),A
        LD      A,1CH                   ; Floppy Seek
        OUT     (FDCCMD),A
l0439:  JR      L0439
        BIT     7,A
        LD      A,53H
l043f:  JR      NZ,L04B7                ; (+76h)
        BIT     2,D
        JR      NZ,L0451                ; (+0ch)
        PUSH    BC
        LD      B,0FAH
l0448:  PUSH    BC
        LD      B,19H
l044b:  DJNZ    L044B                   ; (-02h)
        POP     BC
        DJNZ    L0448                   ; (-08h)
        POP     BC
l0451:  LD      A,05H
        LD      (LE505),A
l0456:  BIT     5,D
        JR      Z,L0469                 ; (+0fh)
        LD      A,(FDCPARAM)
        BIT     4,A
        OUT     (2AH),A
        OUT     (3EH),A
        PUSH    BC
        LD      C,FDCFIFO
        OTIR
        POP     BC
l0469:  LD      A,(FDCPARAM)
        OUT     (2AH),A
        OUT     (3EH),A
        LD      A,(LE53B)
        CP      09H
        JR      Z,L047E                 ; (+07h)
        CP      05H
        LD      A,C
        JR      Z,L0480                 ; (+04h)
        JR      L0489                   ; (+0bh)
l047e:  LD      A,C
        ADD     A,A
l0480:  ADD     A,A
        ADD     A,A
        ADD     A,C
l0483:  SUB     1AH
        JR      NC,L0483                ; (-04h)
        ADD     A,1AH
l0489:  INC     A
        OUT     (FDCSEC),A
        LD      A,D
        RES     2,D
        OUT     (FDCCMD),A              ; Floppy Read / Write? Sector
l0491:  JR      L0491                   ; (-02h)
        AND     0DCH
        JR      NZ,L04B3
        BIT     5,D
        JR      NZ,L04AA                ; (+0fh)
        LD      A,(FDCPARAM)
        RES     4,A
        OUT     (2AH),A
        OUT     (3EH),A
        PUSH    BC
        LD      C,FDCFIFO
        INIR                            ; Read FDC data to RAM.
        POP     BC
l04aa:  INC     C
        LD      A,25
        CP      C
        JR      NC,L0451                ; (-5fh)
        XOR     A
        JR      L04D7                   ; (+24h)
l04b3:  BIT     7,A
        LD      A,44H
l04b7:  JR      NZ,L04C2                ; (+09h)
        LD      A,(LE505)
        DEC     A
        LD      (LE505),A
        JR      NZ,L0456                ; (-6ch)
l04c2:  JR      NZ,L04C6                ; (+02h)
        LD      A,44H
l04c6:  LD      B,A
        LD      HL,(LE449)
        DEC     HL
        LD      A,H
        OR      L
        LD      (LE449),HL
        SCF
        JR      NZ,L04D7                ; (+04h)
        LD      A,B
        OUT     (SIO0D),A
        SCF
l04d7:  RET

; FDC Interrupt Service Routine
FDCISR: EX      (SP),HL
        INC     HL
        INC     HL
        EX      (SP),HL
        IN      A,(FDCSTAT)              ; FDC Status Register
        LD      (FDCSTATUS),A
        EI
        RET
FDUTILS8_END    EQU     $

; Hard Disk Boot
BSCMD:  LD      A,02H
        LD      (LE434),A
        LD      BC,0183H
        LD      DE,RAMUTL               ; Destination for HDC utilities at E100h.
        LD      HL,HDUTILS              ; Source of the HDC utilities.
        LDIR                            ; Copy HDC utilities.
        XOR     A
        LD      (LE41D),A               ; 0 to E41DH ?
        LD      A, 10                   ; 10 Sectors in bootstrap
        LD      (TOTSEC),A              ; ...to E539h
        CALL    RAMUTL                  ; Call HDC bootstrap in RAM.
        JR      C,BSCMD                 ; If the boot failed, try again.
        CALL    LE102                   ; Recalibrate
        JR      C,BSCMD                 ; ... and try again.
        LD      B,00H                   ; Copied by bootstrap into e445.
        LD      DE,0                    ; Copied by bootstrap into e442-e443
        LD      HL,DISKBUF              ; RAM destination to read boot track into.
        CALL    DISKRD                  ; Read HD Bootstrap from disk.
        JR      C,BSCMD                 ; If it fails, retry forever...

; This part of the bootstrap is common to both floppy and hard disks.
BOOTSTRAP:
        LD      BC,0100H                ; Copy one sector
        LD      DE,BOOTSTP              ; ... to C000h
        LD      HL,DISKBUF              ; ... from 8000h
        LDIR                            ; Perform the copy.
        LD      C,20H                   ; Copy boot args, from the second sector of the
        LD      DE,LE520                ; disk to E520h.
        LDIR
        LD      HL,5FD3H                ; Copy the instruction: OUT (5Fh),A
        LD      (ROMDSB),HL             ; ... which disables the ROM, to BFFEh,
        JP      ROMDSB                  ; ... and jump to secondary bootstrap.

; Hard Disk ROM Bootstrap, copied to E100.
;
; Uses a data structure at 0xe444:
;
; 0xe442    Passed in DE registers when calling into bootstrap
; 0xe444    Command? 0=read, written to port 0x40
; 0xe445    Passed in B register when calling into botostrap, written to port 0x441
; 0xe446    Sectors per track, written to port 0x442
; 0xe447    Written to port 0x43
; 0xe448    Remaining sectors to read
HDUTILS:
        JR      HDRESET                 ; E100H
        JR      HDHOME                  ; E102H HOME the disk
        JR      L053B                   ; E104H
        JR      L053B                   ; E106H
        JR      HDREAD                  ; E108H HDC Read
        JP      L06D0                   ; E11AH
l053b:  RET

HDRESET:
        XOR     A
        OUT     (SMDARG0),A
        LD      A,10H
        OUT     (SMDARG1),A
        LD      A,80H
        OUT     (SMDCMD),A
        XOR     A
        OUT     (SMDARG1),A
        LD      A,10H
        OUT     (SMDCMD),A
        LD      B,02H
l0550:  DJNZ    L0550                   ; (-02h)
l0552:  IN      A,(47H)
        XOR     41H
        AND     41H
        JR      Z,L055D                 ; (+03h)
        DJNZ    L0552                   ; (-0ah)
        SCF
l055d:  RET

HDHOME: XOR     A
        OUT     (SMDARG0),A
        LD      A,50H
        OUT     (SMDARG1),A
        LD      A,80H
        OUT     (SMDCMD),A
        XOR     A
        OUT     (SMDARG1),A
        OUT     (SMDCMD),A
        LD      B,02H
l0570:  DJNZ    L0570                   ; (-02h)
l0572:  IN      A,(47H)
        LD      B,A
        BIT     5,B
        JR      NZ,L0588                ; (+0fh)
        BIT     0,B
        JR      Z,L0588                 ; (+0bh)
        XOR     0D0H
        AND     0D0H
        JR      NZ,L0572                ; (-11h)
        LD      A,B
        AND     02H
        JR      Z,L0589                 ; (+01h)
l0588:  SCF
l0589:  RET

; Hard Disk Read (L 0356 in ROM, 0E119H in RAM)
; Track in DE
HDREAD: XOR     A
        OUT     (SMDCMD),A
        OUT     (SMDARG0),A
        OUT     (SMDARG1),A
        LD      (LE502),DE
        LD      A,B
        LD      (LE501),A
        XOR     A
        LD      (LE504),A
        LD      C,44H
l059f:  LD      A,(LE501)
        OUT     (SMDARG1),A
        XOR     A
        OUT     (SMDARG0),A
        LD      A,40H
        OUT     (SMDCMD),A
        LD      B,04H
l05ad:  DJNZ    L05AD                   ; (-02h)
l05af:  IN      A,(47H)
        XOR     41H
        AND     41H
        JR      Z,L05BB                 ; (+04h)
        DJNZ    L05AF                   ; (-0ah)
        JR      L0630                   ; (+75h)
l05bb:  XOR     A
        OUT     (SMDCMD),A
        LD      DE,(LE502)
        LD      A,D
        OUT     (SMDARG0),A
        LD      A,E
        OUT     (SMDARG1),A
        LD      A,20H
        OUT     (SMDCMD),A
        LD      B,04H
l05ce:  DJNZ    L05CE                   ; (-02h)
l05d0:  IN      A,(47H)
        LD      B,A
        BIT     5,B
        JR      NZ,L0648                ; (+71h)
        BIT     0,B
        JR      Z,L0630                 ; (+55h)
        XOR     0D0H
        AND     0D0H
        JR      NZ,L05D0                ; (-11h)
        LD      A,B
        AND     02H
        JR      NZ,L0648                ; (+62h)
        JR      L05EA                   ; (+02h)
l05e8:  JR      L059F                   ; (-4bh)
l05ea:  XOR     A
        LD      (LE506),A
        LD      A,05H
        LD      (LE505),A
        LD      A,(TOTSEC)
        LD      B,A
l05f7:  OUT     (SMDSCID),A
        XOR     A
        OUT     (SMDARG0),A
        OUT     (SMDARG1),A
        OUT     (SMDCMD),A
HD6XX:  PUSH    HL
        LD      HL,(LE506)
        LD      H,00H
        LD      D,H
        LD      E,L
        ADD     HL,HL
        ADD     HL,HL
        ADD     HL,HL
        ADD     HL,DE
        LD      DE,(TOTSEC)
        LD      D,00H
        XOR     A
l0613:  SBC     HL,DE
        JR      NC,L0613                ; (-04h)
        ADD     HL,DE
        LD      A,L
        POP     HL
        OUT     (SMDSEC),A
        LD      (LE500),A
        LD      A,88H
        OUT     (SMDCMD),A
        LD      B,04H
l0625:  DJNZ    L0625                   ; (-02h)
l0627:  IN      A,(47H)
        LD      B,A
        BIT     5,B
        JR      NZ,L0648                ; (+1ah)
        BIT     0,B
l0630:  JR      Z,L06AF                 ; (+7dh)
        XOR     0D0H
        AND     0D0H
        JR      NZ,L0627                ; (-11h)
        BIT     2,B
        JR      NZ,L067A                ; (+3eh)
        LD      A,(LE504)
        OR      A
        JR      Z,L065F                 ; (+1dh)
l0642:  OUT     (SMDSCID),A
        IN      A,(C)
        CP      0AAH
l0648:  JR      NZ,L06AF                ; (+65h)
        IN      D,(C)
        IN      E,(C)
        LD      (LE502),DE
        IN      A,(C)
        LD      (LE501),A
        XOR     A
        LD      (LE504),A
        JR      L05E8                   ; (-75h)
l065d:  JR      L05F7                   ; (-68h)
l065f:  PUSH    BC
        PUSH    HL
        LD      B,04H
        LD      HL,LE503
l0666:  IN      A,(C)
        CP      (HL)
        JR      NZ,L066E                ; (+03h)
        DEC     HL
        DJNZ    L0666                   ; (-08h)
l066e:  POP     HL
        POP     BC
        JR      NZ,L0642                ; (-30h)
        PUSH    BC
        LD      B,00H
        INIR
        POP     BC
        JR      L0694                   ; (+1ah)
l067a:  LD      A,(LE505)
        DEC     A
        LD      (LE505),A
        JR      NZ,L065D                ; (-26h)
        LD      A,(LE504)
        INC     A
        JR      Z,L0694                 ; (+0bh)
        LD      A,(LE506)
        OR      A
        JR      NZ,L06AF                ; (+20h)
        LD      A,0FFH
        LD      (LE504),A
l0694:  LD      A,(LE506)
        INC     A
        LD      (LE506),A
        LD      D,A
        LD      A,(TOTSEC)
        CP      D
        JR      Z,L06A9                 ; (+07h)
        LD      A,05H
        LD      (LE505),A
        JR      L065D                   ; (-4ch)
l06a9:  LD      A,(LE505)
        OR      A
        JR      NZ,L06B0                ; (+01h)
l06af:  SCF
l06b0:  RET

l06b1:  LD      HL,0000
l06b4:  LD      A,(DE)
        INC     DE
        OR      A
        RET     Z

        SUB     30H
        RET     C

        CP      0AH
        CCF
        RET     C

        PUSH    DE
        LD      D,00H
        LD      E,A
        PUSH    DE
        ADD     HL,HL
        LD      D,H
        LD      E,L
        ADD     HL,HL
        ADD     HL,HL
        ADD     HL,DE
        POP     DE
        ADD     HL,DE
        POP     DE
        RET     C

        JR      L06B4                   ; (-1ch)
l06d0:  PUSH    BC
        PUSH    DE
        LD      B,A
        LD      DE,0010H
l06d6:  ADD     HL,HL
        LD      A,D
        RLA
        CP      B
        JR      C,L06DE                 ; (+02h)
        SUB     B
        INC     L
l06de:  LD      D,A
        DEC     E
        JR      NZ,L06D6                ; (-0ch)
        POP     DE
        POP     BC
        RET

L06E5:  LD      HL,0001H
        LD      A,B
        OR      A
        JR      Z,L06EF                 ; (+03h)
l06ec:  ADD     HL,HL
        DJNZ    L06EC                   ; (-03h)
l06ef:  RET

INCMD:  CALL    SPGETBYTE
        LD      C,A
        IN      A,(C)
        CALL    PRSPHEXB
        RET

CICMD:  CALL    SPGETBYTE
        LD      C,A
CICMD1: IN      A,(C)
        CALL    GETCHAR
        JR      CICMD1

OUCMD:  CALL    SPGETBYTE
        LD      C,A
        CALL    SPGETBYTE
        OUT     (C),A
        RET

COCMD:  CALL    OUCMD
        LD      B,A
COCMD1: CALL    GETCHAR
        OUT     (C),B
        JR      COCMD1

FBCMD:  CALL    SPGETBYTE
        LD      HL,DISKBUF
        LD      (HL),A
        LD      DE,8001H
        LD      BC,DBSIZE
        LDIR
        RET

FICMD:  LD      BC,DBSIZE
        LD      HL,DISKBUF
        XOR     A
FICMD1: LD      (HL),A
        INC     A
        INC     HL
        DEC     C
        JR      NZ,FICMD1
        DJNZ    FICMD1
        RET

SPGETBYTE:
        CALL    PRSPACE
        CALL    GETBYTE
        RET

PRSPHEXB:  CALL    PRSPACE
        CALL    PRHEXB
        RET

; DD for 8" drives.
DDCMD:  LD      A,SPT8DD                ; 26 sectors
        JR      SDCMD1

SDCMD:  LD      A,SPT8SD                ; 13 sectors
SDCMD1: LD      (TOTSEC),A
        RET

T0CMD:  CALL    LE102
        RET

; ST for 8" drives.
STCMD:  LD      A,(FDCSTATUS)
        LD      B,A
        LD      HL,L09AC
        CALL    STCMD1
        LD      A,(FDCPARAM)
        LD      B,A
        LD      HL,L09B3
STCMD1: CALL    PRSTRN
        LD      A,B
        CALL    PRSPHEXB
        RET

H1CMD:  LD      A,01H
        JR      H0CMD1
H0CMD:  XOR     A
H0CMD1: LD      (FDHEAD),A
        RET

USCMD:  CALL    PRSPACE
        CALL    WAITCHAR
        SUB     30H
        LD      HL,INVSTR
        JP      C,MONIT
        CP      04H
        JP      NC,MONIT
        LD      (FDUNIT),A
        RET

RTCMD:  CALL    GETTRK
        CALL    DISKRD
        LD      HL,L097C
        JP      C,MONIT
        RET

CRCMD:  CALL    GETTRK
CRCMD1: CALL    GETCHAR
        PUSH    BC
        PUSH    DE
        PUSH    HL
        CALL    DISKRD
        POP     HL
        POP     DE
        POP     BC
        JR      CRCMD1

; Read and validate floppy track from console.
GETTRK: LD      B,02H
        LD      HL,LE402
        PUSH    HL
        POP     DE
        CALL    READCH
        CALL    L06B1
        LD      A,L                     ; Track < 0
        CP      00H
        LD      HL,INVSTR
        JP      C,MONIT                 ; Error, return to monitor.
        CP      4CH                     ; Track >= 76
        JP      NC,MONIT                ; Error, return to monitor.
        LD      E,A
        LD      A,(FDHEAD)
        LD      B,A
        LD      HL,DISKBUF
        RET

; RR command for 8" Floppy Drives
RRCMD:  LD      IY,TRKTBL8
        LD      B,4DH
RRCMD1: PUSH    BC
        LD      A,(FDHEAD)
        LD      B,A
        LD      E,(IY+00H)
        INC     IY
        LD      A,0DH
        LD      H,00H
        LD      L,E
        CALL    PUTC
        CALL    PRHEXW
        LD      HL,DISKBUF
        CALL    DISKRD
        JR      NC,RRCMD2
        CALL    PRPRMPT
RRCMD2: CALL    GETCHAR
        POP     BC
        DJNZ    RRCMD1
        JR      RRCMD
        RET

WRCMD:  CALL    GETTRK
        CALL    LE106
        LD      HL,L097C
        JP      C,MONIT
        RET

CWCMD:  CALL    GETTRK
CWCMD1: CALL    GETCHAR
        PUSH    BC
        PUSH    DE
        PUSH    HL
        CALL    LE106
        POP     HL
        POP     DE
        POP     BC
        JR      CWCMD1

DMCMD:  CALL    GETWORD
        LD      B,10H
DMCMD1: PUSH    BC
        PUSH    HL
        CALL    PRPRMPT
        POP     HL
        CALL    PRHEXW
        CALL    DBLSPC
        LD      B,10H
        PUSH    HL
DMCMD2: LD      A,(HL)
        CALL    PRHEXB
        INC     HL
        DJNZ    DMCMD2
        CALL    DBLSPC
        POP     HL
        LD      B,10H
DMCMD3: LD      A,(HL)
        CALL    PRASC
        INC     HL
        DJNZ    DMCMD3
        POP     BC
        DJNZ    DMCMD1
        RET

SMCMD:  CALL    PRSPACE
        CALL    GETWORD
SMCMD1: LD      A,(HL)
        CALL    PRSPHEXB
        CALL    PRSPACE
        CALL    WAITCHAR
        CP      20H
        JR      Z,SMCMD3                 ; (+0eh)
        LD      B,00H
        PUSH    HL
        LD      HL,SMCMD2
        EX      (SP),HL
        CALL    ATOX
SMCMD2: CALL    L0F98
        LD      (HL),A
SMCMD3: INC     HL
        PUSH    HL
        CALL    PRPRMPT
        POP     HL
        CALL    PRHEXW
        JR      SMCMD1                   ; (-27h)

; Loop through all SIO ports
SICMD:  LD      C,SIO0D
SICMD1: IN      A,(C)
        OUT     (C),A
        INC     C
        INC     C
        LD      A,C
        CP      15H
        JR      C,SICMD1
        JR      NZ,SICMD2
        LD      C,2DH
        JR      SICMD1
SICMD2: CP      38H
        JR      C,SICMD1
        JR      SICMD
SICMD3: LD      C,SIO0D
        LD      B,08H
SICMD4: IN      A,(C)
        OUT     (C),A
        INC     C
        INC     C
        DJNZ    SICMD4
        JR      SICMD3

TRCMD:  LD      HL,DISKBUF
        LD      C,0C0H
l08a3:  LD      B,00H
l08a5:  IN      A,(C)
        LD      (HL),A
        INC     HL
        SET     5,C
        IN      A,(C)
        LD      (HL),A
        INC     HL
        RES     5,C
        LD      A,08H
        ADD     A,B
        LD      B,A
        JR      NC,L08A5                ; (-12h)
        INC     C
        LD      A,C
        CP      0E0H
        JR      C,L08A3                 ; (-1ah)
        RET

L08BF:  DB      0DH, 09H

; 77-track Floppy
TRKTBL8:
        DB      4CH, 25H, 4BH, 24H, 4AH, 23H, 49H, 22H
        DB      48H, 21H, 47H, 20H, 46H, 1FH, 45H, 1EH
        DB      44H, 1DH, 43H, 1CH, 42H, 1BH, 41H, 1AH
        DB      40H, 19H, 3FH, 18H, 3EH, 17H, 3DH, 16H
        DB      3CH, 15H, 3BH, 14H, 3AH, 13H, 39H, 12H
        DB      38H, 11H, 37H, 10H, 36H, 0FH, 35H, 0EH
        DB      34H, 0DH, 33H, 0CH, 32H, 0BH, 31H, 0AH
        DB      30H, 09H, 2FH, 08H, 2EH, 07H, 2DH, 06H
        DB      2CH, 05H, 2BH, 04H, 2AH, 03H, 29H, 02H
        DB      28H, 01H, 27H, 00H, 26H

CMDTBL:
        DB      'IN'
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
        DB      'DD'
        DW      DDCMD
        DB      'SD'
        DW      SDCMD
        DB      'T0'
        DW      T0CMD
        DB      'ST'
        DW      STCMD
        DB      'H1'
        DW      H1CMD
        DB      'H0'
        DW      H0CMD
        DB      'US'
        DW      USCMD
        DB      'RT'
        DW      RTCMD
        DB      'CR'
        DW      CRCMD
        DB      'RR'
        DW      RRCMD
        DB      'WR'
        DW      WRCMD
        DB      'CW'
        DW      CWCMD
        DB      'DM'
        DW      DMCMD
        DB      'SM'
        DW      SMCMD
        DB      'BF'
        DW      BFCMD
        DB      'BS'
        DW      BSCMD
        DB      'SI'
        DW      SICMD
        DB      'TR'
        DW      TRCMD
        DB      'MT'
        DW      MTCMD

INVSTR: DB      INVSTRLEN
        DB      ' - invalid'
INVSTRLEN EQU   $ - INVSTR - 1
L097C:  DB      DESTRLEN
        DB      ' - disk err'
DESTRLEN EQU    $ - L097C - 1
L0988:  DB      10H     ; This is a bug in the orignal ROM, should be SESTRLEN
        DB      ' - restore/seek error'
SESTRLEN EQU    $ - L0988 - 1
L099E:  DB      RESTRLEN
        DB      ' - read error'
RESTRLEN EQU    $ - L099E - 1
L09AC:  DB      ATUSTRLEN
        DB      'ATUS -'
ATUSTRLEN EQU $ - L09AC - 1
L09B3:  DB      PARSTRLEN
        DB      ' PARAM -'
PARSTRLEN EQU $ - L09B3 - 1

; Memory Test Command
MTCMD:
        LD      A,03H
        OUT     (SIO0S),A
        LD      A,11H
        OUT     (SIO0S),A
        LD      IY,L09CB
        JP      OUTCRLF
l09cb:  LD      IY,L09D5
        LD      DE,L0B51
        JP      OUTSTRQ
L09D5:  IN      A,(SIO0D)
        AND     7FH
        CP      41H
        JR      Z,L09E5                 ; (+08h)
        CP      30H
l09df:  JR      C,L09CB                 ; (-16h)
        CP      32H
        JR      NC,L09CB                ; (-1ah)
l09e5:  EXX
        LD      C,A
        EXX
l09e8:  LD      IY,L09F2
        LD      DE,L0BCC
        JP      OUTSTRQ
L09F2:  IN      A,(SIO0D)
        AND     7FH
        CP      41H
        JR      Z,L0A02                 ; (+08h)
        CP      30H
        JR      C,L09E8                 ; (-16h)
        CP      3AH
        JR      NC,L09E8                ; (-1ah)
l0a02:  EXX
        LD      L,A
        EXX
        EXX
l0a06:  LD      B,30H
        EXX
l0a09:  EXX
        LD      A,B
        CP      3AH
l0a0d:  JP      Z,L09CB
        LD      A,L
        CP      41H
        JR      Z,L0A16                 ; (+01h)
l0a15:  CP      B
l0a16:  EXX
        JP      NZ,L0AE2
        LD      IY,0A24H
        LD      DE,L0BF5
        JP      OUTSTR
        EXX
        LD      A,B
        EXX
        LD      IX,0A2EH
        JP      OUTCHR
        EXX
        LD      A,B
        EXX
        AND     0FH
; 0x0ADA: Bank select register
        OUT     (38H),A
        LD      A,01H
        LD      (8001H),A
        LD      (8002H),A
        LD      A,(8001H)
        CP      01H
        JR      Z,L0A55                 ; (+11h)
        LD      A,(8002H)
        CP      01H
        JR      Z,L0A55                 ; (+0ah)
        LD      IY,L0AE2
        LD      DE,L0BFD
        JP      OUTSTR
l0a55:  EXX
        LD      A,C
        EXX
        CP      31H
        JR      Z,L0A77                 ; (+1bh)
        LD      C,00H
l0a5e:  LD      IY,0A65H
        JP      L0AE9
        LD      IY,0A6CH
        JP      L0B47
        INC     C
        JR      NZ,L0A5E                ; (-11h)
        EXX
        LD      A,C
        EXX
        CP      41H
        JP      NZ,L0AE2
l0a77:  LD      C,00H
        LD      IY,0A80H
        JP      L0AE9
        LD      IY,0A8EH
        LD      A,64H
        LD      I,A
        LD      DE,0C60H
        JP      OUTSTR
        LD      HL,DISKBUF
l0a91:  LD      DE,DISKBUF
        LD      (HL),0FFH
l0a96:  LD      A,D
        OR      E
        JR      Z,L0ABD                 ; (+23h)
        LD      A,D
        CP      H
        JR      NZ,L0AA2                ; (+04h)
        LD      A,E
        CP      L
        JR      Z,L0AAE                 ; (+0ch)
l0aa2:  LD      A,(DE)
        LD      C,00H
        LD      B,A
        CP      C
        LD      IY,L0AAE
        JP      NZ,L0C8E
l0aae:  LD      A,E
        OR      A
        JR      Z,L0AB9                 ; (+07h)
        RLA
        LD      E,A
        JR      NC,L0A96                ; (-20h)
        INC     D
        JR      L0A96                   ; (-23h)
l0ab9:  LD      E,01H
        JR      L0A96                   ; (-27h)
l0abd:  LD      B,(HL)
        LD      A,0FFH
        LD      C,A
        CP      B
        LD      IY,0AC9H
        JP      NZ,L0D63
        LD      A,I
        DEC     A
        LD      I,A
        LD      A,64H
        JR      NZ,L0ADB                ; (+09h)
        LD      I,A
        LD      IY,L0ADB
        JP      L0B47
l0adb:  LD      (HL),00H
        INC     HL
        LD      A,H
        OR      L
        JR      NZ,L0A91                ; (-51h)
l0ae2:  EXX
        INC     B
        INC     H
        EXX
        JP      L0A09
l0ae9:  LD      HL,7FFFH
l0aec:  INC     HL
        LD      (HL),C
        LD      A,H
        OR      L
        JR      NZ,L0AEC                ; (-06h)
        LD      HL,DISKBUF
l0af5:  LD      A,(HL)
        LD      B,A
        CP      C
        JR      NZ,L0B01                ; (+07h)
        INC     HL
        LD      A,H
        OR      L
        JR      NZ,L0AF5                ; (-0ah)
        JP      (IY)
l0b01:  LD      IY,L0AE2
        JP      L0D63

; Print 0-terminated strint pointed to by DE and read a character from the SIO.
; Return address in IY
OUTSTRQ:
        LD      IX,0B0CH
        LD      A,(DE)
        INC     DE
        OR      A
        JR      NZ,OUTCHR                ; (+18h)
WAITCH: IN      A,(SIO0S)
        AND     01H
        JR      Z,WAITCH
        IN      A,(SIO0D)
        OUT     (SIO0D),A
        JP      OUTCRLF

; Print 0-terminated strint pointed to by DE.
; Return address in IY
OUTSTR: LD      IX,0B22H
        LD      A,(DE)
        INC     DE
        OR      A

; Output a character in A to the SIO.
        JR      NZ,OUTCHR                ; (+02h)
        JP      (IY)
OUTCHR:  EX      AF,AF'
l0b2a:  IN      A,(SIO0S)
        AND     02H
        JR      Z,L0B2A                 ; (-06h)
        EX      AF,AF'
        OUT     (SIO0D),A
        JP      (IX)

; Output a CR/LF to the SIO.
OUTCRLF:  LD      A,0DH
        LD      IX,0B3DH
        JR      OUTCHR                   ; (-14h)
        LD      A,0AH
        LD      IX,0B45H
        JR      OUTCHR                   ; (-1ch)
        JP      (IY)

; Output a period to the SIO.
l0b47:  LD      A,2EH
        LD      IX,0B4FH
        JR      OUTCHR                   ; (-26h)
        JP      (IY)

L0B51:  DB      CR, LF, 'IBC MIDDI-CADET Memory Test'
        DB      CR, LF, 'test # 0 - cell test'
        DB      CR, LF, 'test # 1 - row/column sensitivity test'
        DB      CR, LF, 'select test (0,1 or A<all>)? ', 0
L0BCC:  DB      CR, LF, 'which bank to select (0-9 or A<all>)? ', 0
L0BF5:  DB      CR, LF, 'Bank ', 0
L0BFD:  DB      '  not found ', CR, LF, 0
L0C0C:  DB      CR, LF, 'ERBC address=', 0
L0C1C:  DB      '; Read=', 0
L0C24:  DB      '; Expected=', 0
L0C30:  DB      '; Test cell address=', 0
L0C45:  DB      '; Pattern=', 0
L0C50:  DB      CR, LF, 'ERTC address=', 0
L0C60:  DB      CR, LF, 'Now entering Row/Column sensitivity tests', CR, LF, 0

l0c8e:  EXX
        LD      SP,IY
        LD      IY,L0C98
        JP      L0DF2
l0c98:  LD      IY,0CA2H
        LD      DE,L0C0C
        JP      OUTSTR
        EXX
        LD      IY,0CAAH
        JP      L0DB4
        EXX
        LD      IY,0CB5H
        LD      DE,0C1CH
        JP      OUTSTR
        EXX
        LD      A,B
        LD      IY,0CBEH
        JP      L0DA0
        EXX
        LD      DE,0C24H
l0cc2:  LD      IY,0CC9H
        JP      OUTSTR
        EXX
        LD      A,C
        LD      IY,0CD2H
        JP      L0DA0
        EXX
        LD      DE,0C30H
        LD      IY,0CDDH
        JP      OUTSTR
        EXX
        EX      DE,HL
        LD      IY,0CE6H
        JP      L0DB4
        EX      DE,HL
        EXX
        LD      IY,0CF2H
        LD      DE,0C45H
        JP      OUTSTR
        EXX
        LD      IY,L0CFB
        LD      A,C
        JP      L0DA0
l0cfb:  EXX
        LD      B,00H
        LD      C,0E0H
        IN      A,(C)
        LD      D,A
        LD      IX,0D0AH
        JP      L0E54
        RRCA
        RRCA
        RRCA
        RRCA
        AND     0FH
        OR      D
        LD      D,A
        LD      IX,0D19H
        JP      L0E54
        LD      E,C
        LD      IX,0D21H
        JP      L0E54
        RRCA
        RRCA
        RRCA
        RRCA
        AND     0FH
        OR      E
        LD      E,A
        LD      IX,0D30H
        JP      L0E54
        LD      H,A
        LD      IX,0D38H
        JP      L0E54
        RRCA
        RRCA
        RRCA
        RRCA
        AND     0FH
        OR      H
        LD      H,A
        LD      IX,0D47H
        JP      L0E54
        LD      L,A
        LD      IX,0D4FH
        JP      L0E54
        RRCA
        RRCA
        RRCA
        RRCA
        AND     0FH
        OR      L
        LD      L,A
        LD      B,D
        LD      C,E
        EXX
        LD      IY,0
        ADD     IY,SP
        JP      OUTCRLF
l0d63:  EXX
        LD      SP,IY
        LD      IY,0D6DH
        JP      L0DF2
        LD      IY,0D77H
        LD      DE,L0C50
        JP      OUTSTR
        EXX
        EX      DE,HL
        LD      IY,0D80H
        JP      L0DB4
        EX      DE,HL
        EXX
        LD      IY,0D8CH
        LD      DE,0C1CH
        JP      OUTSTR
        EXX
        LD      A,B
        LD      IY,0D95H
        JP      L0DA0
        EXX
        LD      IY,0CF2H
        LD      DE,0C24H
        JP      OUTSTR
l0da0:  EXX
        LD      B,A
        RRA
        RRA
        RRA
        RRA
        LD      HL,0DABH
        JR      L0DE2                   ; (+37h)
        LD      A,B
        LD      HL,0DB1H
        JR      L0DE2                   ; (+31h)
        EXX
        JP      (IY)
l0db4:  LD      A,D
        EXX
        RRA
        RRA
        RRA
        RRA
        LD      HL,0DC0H
        JP      L0DE2
        EXX
        LD      A,D
        EXX
        LD      HL,0DC9H
        JP      L0DE2
        EXX
        LD      A,E
        EXX
        LD      HL,0DD6H
        RRA
        RRA
        RRA
        RRA
        JP      L0DE2
        EXX
        LD      A,E
        EXX
        LD      HL,0DDFH
        JP      L0DE2
        EXX
        JP      (IY)
l0de2:  AND     0FH
        ADD     A,90H
        DAA
        ADC     A,40H
        DAA
        LD      IX,0DF1H
        JP      OUTCHR
        JP      (HL)
l0df2:  LD      D,B
        LD      E,C
        LD      C,0E0H
        LD      B,00H
        LD      A,D
        LD      IX,0E00H
        JP      L0E4A
        LD      A,D
        RLCA
        RLCA
        RLCA
        RLCA
        LD      IX,0E0CH
        JP      L0E4A
        LD      A,E
        LD      IX,0E14H
        JP      L0E4A
        LD      A,E
        RLCA
        RLCA
        RLCA
        RLCA
        LD      IX,0E20H
        JP      L0E4A
        LD      A,H
        LD      IX,0E28H
        JP      L0E4A
        LD      A,H
        RLCA
        RLCA
        RLCA
        RLCA
        LD      IX,0E34H
        JP      L0E4A
        LD      A,L
        LD      IX,0E3CH
        JP      L0E4A
        LD      A,L
        RLCA
        RLCA
        RLCA
        RLCA
        LD      IX,0E48H
        JP      L0E4A
        JP      (IY)
l0e4a:  AND     0F0H
        OUT     (C),A
        LD      A,08H
        ADD     A,B
        LD      B,A
        JP      (IX)
l0e54:  LD      A,08H
        ADD     A,B
        LD      B,A
        IN      A,(C)
        JP      (IX)
        LD      IY,0E66H
        LD      DE,TRANSM
        JP      OUTSTR
        LD      H,55H
        LD      SP,0E6EH
        JP      L0E82
        LD      SP,0E74H
        JP      L0E99
        LD      H,0AAH
        LD      SP,0E7CH
        JP      L0E82
        LD      SP,0
        JP      L0E99
l0e82:  LD      C,0C0H
l0e84:  LD      B,00H
l0e86:  OUT     (C),H
        LD      A,08H
        ADD     A,B
        LD      B,A
        JR      NC,L0E86                ; (-08h)
        INC     C
        JR      NZ,L0E84                ; (-0dh)
        LD      IY,0
        ADD     IY,SP
        JP      (IY)
l0e99:  LD      C,0C0H
l0e9b:  LD      B,00H
l0e9d:  IN      A,(C)
        CP      H
        JR      NZ,L0EB3                ; (+11h)
        LD      A,08H
        ADD     A,B
        LD      B,A
        JR      NC,L0E9D                ; (-0bh)
        INC     C
        JR      NZ,L0E9B                ; (-10h)
        LD      IY,0
        ADD     IY,SP
        JP      (IY)
l0eb3:  LD      A,H
        EXX
        LD      D,A
        EXX
        LD      DE,0F42H
        LD      IY,0EC1H
        JP      OUTSTR
        LD      A,C
        AND     1FH
        LD      IY,0ECBH
        JP      L0DA0
        LD      A,C
        CP      0E0H
        LD      DE,L0F6B
        JR      C,L0ED6                 ; (+03h)
        LD      DE,L0F63
l0ed6:  LD      IY,0EDDH
        JP      OUTSTR
        LD      DE,L0F4A
        LD      IY,0EE7H
        JP      OUTSTR
        LD      A,B
        RRCA
        RRCA
        RRCA
        AND     1FH
        LD      IY,0EF4H
        JP      L0DA0
        LD      DE,L0F52
        LD      IY,0EFEH
        JP      OUTSTR
        IN      A,(C)
        LD      IY,0F07H
        JP      L0DA0
        LD      DE,L0F57
        LD      IY,0F11H
        JP      OUTSTR
        EXX
        LD      A,D
        EXX
        LD      IY,0F1BH
        JP      L0DA0
        EXX
        LD      A,D
        EXX
        LD      H,A
l0f1f:  JP      L0F1F

TRANSM: DB      CR, LF, 'Translation Ram Memory test', CR, LF, 00H
L0F42:  DB      CR, LF, 'bank ', 00H
L0F4A:  DB      ' block ', 00H
L0F52:  DB      ' is ', 00H
L0F57:  DB      ' should be ', 00H
L0F63:  DB      ' upper ', 00H
L0F6B:  DB      ' lower ', 00H


; Read B characters into memory at HL.
READCH: CALL    PRSPACE
READCH1:
		CALL    WAITCHAR
        CP      0DH
        JR      Z,ISCR
        CP      08H
        JR      NZ,NOTBS
        INC     B
        DEC     HL
        JR      READCH1
NOTBS:  LD      (HL),A
        INC     HL
        DJNZ    READCH1
ISCR:   XOR     A
        LD      (HL),A
        RET

; Read Hex 16 bits from Console into HL
GETWORD:
        CALL    GETBYTE
        LD      H,A
        CALL    GETBYTE
        LD      L,A
        RET

; Read Hex Byte from Console into A
GETBYTE:
        CALL    L0F9C
l0f98:  RLA
        RLA
        RLA
        RLA
l0f9c:  PUSH    BC
        AND     0F0H
        LD      B,A
        CALL    WAITCHAR
ATOX:   SUB     '0'                     ; Convert ASCII to Hex
        JR      C,PRINVAL
        CP      0AH
        JR      C,ATOX1
        SUB     07H
        JR      C,PRINVAL
        CP      10H
        JR      NC,PRINVAL
ATOX1:  OR      B
        POP     BC
        RET

WAITCHAR:
        CALL    CONSTAT
        JR      Z,WAITCHAR                 ; (-05h)
        CALL    GETCHAR
        RET

; Check if character is available from the console.
CONSTAT:
        LD      A,(SIOBASE)
        PUSH    BC
        LD      C,A
        IN      A,(C)
        BIT     0,A
        POP     BC
        RET

; GETCHAR - Read character from Console, return to Monitor if ESC.
GETCHAR:
        PUSH    BC
        CALL    CONSTAT
        JR      Z,L0FE7                 ; (+17h)
        LD      A,(SIOBASE)             ; Base of SIO (Status)
        INC     A                       ; SIO Data Port
        LD      C,A
        IN      A,(C)                   ; Read from SIO Data Port
        AND     7FH                     ; 7-bit ASCII
        CP      'a'                     ; Check if lower case.
        JR      C,GETCHAR1                 ; Already upper case.
        RES     5,A                     ; Convert to upper case.
GETCHAR1:
        CP      ESC                     ; If ESC,
        JP      Z,REINIT                ; ... return to monitor.
        CALL    PUTC                    ; Echo the character to the console
l0fe7:  POP     BC
        RET

PRINVAL:
        LD      HL,INVSTR               ; ' - invalid'
MONIT:  CALL    PRSTRN
REINIT: LD      SP,STKTOP
        JP      ROMMON                  ; Signon and command prompt.
; The following code runs if there is an NMI.  The purpose is to
; test the RAM in the machine.  As such, no RAM variables or stack
; are utilized.  Instead, registers are used to hold all state.
;
; Memory Parity Error, do RAM test...
PARERR: LD      DE,PERRSTR              ; 'Memory Parity Error!!! (ESC or M)', 07H, 0
        LD      IY,PERR1
        JP      OUTSTR

PERR1:  IN      A,(SIO0S)
        AND     01H
        JR      Z,PERR1
        IN      A,(SIO0D)
        AND     5FH
        CP      ESC                     ; ESC, reset to 0.
        JP      Z,START
        CP      'M'                     ; 'M'
        JP      Z,MTCMD
        JR      PARERR
PRPRMPT:
        LD      HL,PROMPT
PRSTRN: PUSH    BC                      ; Print counted string, count is in first byte.
        LD      B,(HL)
PRSTLP: INC     HL
        LD      A,(HL)
        CALL    PUTC
        DJNZ    PRSTLP
        POP     BC
        RET

PRHEXW: LD      A,H
        CALL    PRHEXB
        LD      A,L
PRHEXB: PUSH    AF
        RRA
        RRA
        RRA
        RRA
        CALL    PRHNIB                  ; Print upper nibble
        POP     AF                      ; Get lower nibble
PRHNIB: AND     0FH                     ; Convert nibble to Hex and print.
        ADD     A,'0'
        CP      ':'
        JR      C,PRASC
        ADD     A,07H

; Print ASCII character in A.  If non printable, replace with a period.
PRASC:  CP      ' '
        JR      C,PRASC1
        CP      80H
        JR      C,PUTC
PRASC1: LD      A,'.'
PUTC:   PUSH    BC
        LD      B,A
        LD      A,(SIOBASE)             ; 0xe41a contains I/O port for console.
        LD      C,A
SIORDY: IN      A,(C)                   ; SIO Status port
        BIT     1,A                     ; Transmitter ready?
        JR      Z,SIORDY                ; No, loop until ready.
        INC     C                       ; Move to SIO data port.
        OUT     (C),B                   ; Write char in B to SIO.
        LD      A,B
        POP     BC
        RET

DBLSPC: CALL    PRSPACE                 ; Print two spaces
PRSPACE:
        PUSH    AF                      ; Print space
        LD      A,20H
        CALL    PUTC
        POP     AF
        RET
PERRSTR:
        DB      'Memory Parity Error!!! (ESC or M)', 07H, 0     ; 0x0F1B
PROMPT: DB      03, CR, LF, '*' ; 0x0F3E
