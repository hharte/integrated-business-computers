; IBC/Integrated Business Computers
; MultiStar* SERIES Loader PROM  V3.4
;
; Partial disassembly of IBC_DMP011_REV_L.bin
; The PROM is a 2764 (8K*8) EPROM.
;
; Assemble with the zmac assembler: http://48k.ca/zmac.html
;
; The Loader PROM supports the following disk controllers:
;     WD1795 with external FIFO, interrupt driven (8" or 5.25".)
;     WD1795 without external FIFO, polled (5.25".)
;     IBC Disk Slave (ST-506) Hard Disk Controller.
;
CR      EQU     0DH
LF      EQU     0AH

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
LE520   EQU     0E520H                  ; First 32 bytes of the second sector of the boostrap (boot arguments?)

LE505   EQU     0E505H                  ; Used by Floppy bootstrap
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

DIPSW   EQU     03CH                    ; IBC MCC DIP Switch at location E.

; DIP Switch Bits:
SW_ROMMON       EQU     00H             ; Enter ROM monitor if ON, auto boot if OFF.
SW_HDBOOT       EQU     01H             ; Boot Hard Disk if ON, boot Floppy if OFF.
SW_RAMTEST      EQU     02H             ; Run RAM test if ON.
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
        IN      A,(TIMER)               ; Read status registers to clear any pending interrupts
        IN      A,(FDCSTAT)             ; FDC
        IN      A,(80H)                 ; ?
        XOR     A
        OUT     (62H),A
        OUT     (HDCCMD),A
        OUT     (44H),A
        OUT     (47H),A

; Zero all 64K of RAM
        LD      BC,0000
        LD      HL,0000
ZEROLP: LD      (HL),A
        INC     HL
        DEC     C
        JR      NZ,ZEROLP               ; (-05h)
        DJNZ    ZEROLP                  ; (-07h)

; Reset Serial Ports
        LD      A, ACIA_MR              ; Master Reset ACIA
        LD      BC,0A00H                ; 10 MC6850 UARTs
l0022:  OUT     (C),A                   ; Control register
        INC     C
        IN      D,(C)                   ; Clear Data register
        INC     C
        DJNZ    L0022                   ; (-08h)


        LD      SP,STKTOP               ; Initialize stack pointer
        LD      A,0E1H
        LD      I,A                     ; Set IM2 vector to 0E1xx.
        LD      DE,FDUTILS8             ; Start of 8" Floppy utility code.
        LD      HL,FDUTILS8_END         ; End of 8" floppy utility code.
        IN      A,(DIPSW)               ; Read DIP switch E.
        BIT     SW_FDCTYPE,A            ; Check switch position 7
        JR      NZ,L0063                ; 8" Floppy, skip the FIFO check.

; Determine whether the Floppy Controller has the external FIFO available.
L003D:  XOR     A
        OUT     (3EH),A                 ; Reset FIFO
        OUT     (FDCFIFO),A             ; Write 0 to FIFO
        INC     A
        OUT     (FDCFIFO),A             ; Write 1 to FIFO
        INC     A
        OUT     (FDCFIFO),A             ; Write 2 to FIFO
        OUT     (3EH),A                 ; Reset FIFO
        IN      A,(FDCFIFO)             ; Read from FIFO
        OR      A                       ; Make sure we read a 0
        JR      NZ,NOFIFO               ; Error, no FIFO.
        IN      A,(FDCFIFO)
        CP      01H                     ; Make sure we read a 1
        JR      NZ,NOFIFO               ; Error, no FIFO.
        IN      A,(FDCFIFO)
        CP      02H                     ; Make sure we read a 2
        JR      NZ,NOFIFO               ; Error, no FIFO.
        JR      L0063                   ; FIFO is ok, use it.

; No FIFO, use the WD1795's Data Register with polling instead.
NOFIFO: LD      DE,FDUTILS5
        LD      HL,FDUTILS5_END

l0063:  JR      L006C                   ; (+07h)

        ORG     0066H
NMIISR:
        NOP
        NOP
        JP      PARERR                 ; If there is an NMI, jump to the RAM test.
        NOP

l006c:  PUSH    DE
        XOR     A
        OUT     (1CH),A
        SBC     HL,DE
        PUSH    HL
        POP     BC                      ; length of FDC utilities in BC
        LD      DE,RAMUTL
        POP     HL
        LDIR                            ; Copy FDC utilities to RAM at E100H.
        IN      A,(FDCSTAT)
        LD      DE,RAMUTL
        LD      HL,(FDCVEC)
        ADD     HL,DE                   ; Add E100H to FDC Interrupt Vector
        LD      (FDCVEC),HL             ; Update FDC interrupt vector.
        IM      2                       ; Set interrupt mode 2.
        EI                              ; Enable interrupts.

; Copy 'SYSTEM NUCLEUS ' to BFNAME
        LD      BC,0011H
        LD      DE,BFNAME
        LD      HL,l014D
        LDIR

; Initialize serial ports to 38400,8,n,1
        LD      A,ACIA_16 OR ACIA_82    ; Divide by 16, 8 data bits, 2 stop bits.
        LD      BC,0A00H
INITLP: OUT     (C),A                   ; Write ACIA Control register
        INC     C
        INC     C
        DJNZ    INITLP

l009f:  IN      A,(DIPSW)               ; Read DIP switch E.
        BIT     SW_RAMTEST,A            ; Check switch 3=ON
        JP      Z,RAMTEST               ; ... if so, run RAM test.
        BIT     SW_PORT20H,A            ; SW E-8: OFF = , ON = ? Related to MMU?
        JR      NZ,L00AE
        LD      A,01H
        OUT     (20H),A                 ; What does port 20H do?
l00ae:  IN      A,(DIPSW)               ; Read DIP switch E.
        BIT     SW_ROMMON,A             ; SW E-1: OFF = Auto Boot, ON = ROM Monitor
        JR      Z,ROMMON                ; ROM Monitor
        BIT     SW_HDBOOT,A             ; SW E-2: Auto boot device: OFF = Floppy, ON = HDC
        JP      Z,BSCMD                 ; Automatically boot Hard Disk

        LD      A,30H
        OUT     (2AH),A                 ; Write PARAM register
        LD      (FDCPARAM),A
        IN      A,(FDCSTAT)             ; Check FDC Status register
        BIT     7,A                     ; Is drive ready?
        JP      Z,BFCMD                 ; Automatically boot Floppy Disk.

ROMMON: XOR     A
l00c8:  LD      (SIOBASE),A
        CALL    GETCHAR
        LD      A,(SIOBASE)
        INC     A
        INC     A
        CP      14H
        JR      NC,L009F
        JR      L00C8
l00d9:  LD      HL,SIGNON               ; ' MultiStar* SERIES   Loader PROM  V3.4'
        CALL    L0ED1
L00DF:  CALL    L0ECE
l00e2:  CALL    GETCHAR
        JR      Z,L00E2
        LD      DE,L00DF
        PUSH    DE
        LD      H,A
        CALL    L0E6F
        LD      L,A
        PUSH    HL
        LD      B,19H
        LD      HL,CMDTBL8              ; Point to command table for 8" Floppy (77 tracks)
        IN      A,(DIPSW)               ; Read DIP switch E.
        BIT     SW_FDCTYPE,A            ; Check if Floppy is 5.25" or 8"
        JR      NZ,L00FF                ; 8" Floppy
        LD      HL,CMDTBL5              ; Point to command table for 5.25" Floppy (80 tracks)
l00ff:  LD      D,(HL)
        INC     HL
        LD      E,(HL)
        INC     HL
        EX      (SP),HL
        PUSH    HL
        XOR     A
        SBC     HL,DE
        POP     HL
        JR      NZ,L0111                ; (+06h)
        POP     HL
        LD      E,(HL)
        INC     HL
        LD      D,(HL)
        PUSH    DE
        RET

l0111:  EX      (SP),HL
        INC     HL
        INC     HL
        DJNZ    L00FF                   ; (-17h)
        POP     HL
        LD      HL,L08D2                ; ' - invalid'
        JP      MONIT

SIGNON  DB      02Fh, CR, LF, 'IBC MultiStar* SERIES   Loader PROM  V3.4 ', CR, LF, LF
SIGNON_LEN EQU  $ - SIGNON - 1
l014D:  DB      'SYSTEM  NUCLEUS ', 0

BFCMD:  XOR     A                       ; L 015E
        OUT     (HDCCMD),A              ; Write HD
        OUT     (44H),A
        LD      B,SPT5
l0165:  IN      A,(DIPSW)               ; Read DIP switch E.
        BIT     SW_FDCTYPE,A            ; 8" or 5.25" drives?
        JR      Z,L016D                 ; 5.25" floppy
        LD      B,SPT8DD
l016d:  LD      A,B
        LD      (TOTSEC),A
        XOR     A
l0172:  LD      (FDUNIT),A
l0175:  LD      (LE53B),A
        CALL    LE102
        LD      B,00H
        LD      E,00H
        LD      HL,DISKBUF
        CALL    DISKRD                  ; Read track from disk
l0185:  JR      C,BFCMD                 ; Error, retry forever.
        JP      L0322

; Floppy Utilities for 8" controller, copied to e100.
FDUTILS8:
        XOR     A
        RET
l018c:  JR      L0197
l018e:  DW      FDCISR - FDUTILS8       ; E104: Offset of FDC ISR from beginning of FDUTILS8.
l0190:  JR      L01A7
        JR      L019D
        JP      L05C0
l0197:  LD      A,01H
        LD      (LE41C),A
        RET

l019d:  LD      D,8CH
        BIT     0,B
        JR      Z,L01AF
        SET     1,D
        JR      L01AF
L01A7:  LD      D,0ACH
        BIT     0,B
        JR      Z,L01AF
        SET     1,D
l01af:  LD      C,00H
        PUSH    HL
        LD      HL,LE416
        LD      A,(FDUNIT)
        AND     03H
        ADD     A,L
        LD      L,A
        JR      NC,L01BF
        INC     H
l01bf:  EX      (SP),HL
        POP     IX
        LD      A,(FDUNIT)
        OR      38H
        BIT     5,D
        JR      Z,L01CD
        RES     5,A
l01cd:  BIT     0,B
        JR      Z,L01D3
        SET     2,A
l01d3:  LD      B,A
        IN      A,(DIPSW)               ; Read DIP switch E.
        BIT     SW_FDCTYPE,A
        JR      NZ,L01DE                ; 8" Floppy
        SET     6,B
        JR      L01FA
l01de:  LD      A,(TOTSEC)
        CP      0EH
        JR      C,L01F3
        XOR     A
        CP      E
        JR      NZ,L01FA
        LD      A,(LE53B)
        OR      A
        JR      Z,L01F3
        BIT     2,B
        JR      NZ,L01FA
l01f3:  LD      A,B
        LD      B,80H
        RES     3,A
        JR      L01FD
l01fa:  LD      A,B
        LD      B,00H
l01fd:  OUT     (2AH),A                 ; Write PARAM register
        LD      (FDCPARAM),A
        LD      A,B
        LD      (LE41D),A
l0206:  IN      A,(FDCSTAT)             ; FDC Status Register
        BIT     0,A
        JR      NZ,L0206                ; Wait for FDC not busy.
        BIT     7,A
        JR      NZ,L024B
        LD      A,(LE41C)
        RRA
        JR      NC,L0229
        LD      A,0CH                   ; Restore
        OUT     (FDCSTAT),A             ; FDC Command
l021a:  JR      L021A
        BIT     7,A
        LD      A,52H
        JR      NZ,L024B
        XOR     A
        LD      (LE41C),A
        LD      (IX+00H),A
l0229:  LD      A,(IX+00H)
        OUT     (FDCTRK),A
        LD      A,0AH
l0230:  DEC     A
        JR      NZ,L0230
        IN      A,(FDCSTAT)             ; FDC Status Register
        BIT     7,A
        LD      A,73H
        JR      NZ,L024B
        LD      A,E
        LD      (IX+00H),A
        OUT     (FDCDATA),A
        LD      A,1CH                   ; Floppy Seek
        OUT     (FDCCMD),A
l0245:  JR      L0245                   ; (-02h)
        BIT     7,A
        LD      A,53H
l024b:  JR      NZ,L02CB                ; (+7eh)
        BIT     2,D
        JR      NZ,L025D                ; (+0ch)
        PUSH    BC
        LD      B,0FAH
l0254:  PUSH    BC
        LD      B,19H
l0257:  DJNZ    L0257                   ; (-02h)
        POP     BC
        DJNZ    L0254                   ; (-08h)
        POP     BC
l025d:  LD      A,05H
        LD      (LE505),A
l0262:  BIT     5,D
        JR      Z,L0275                 ; (+0fh)
        LD      A,(FDCPARAM)
        BIT     4,A
        OUT     (2AH),A
        OUT     (3EH),A
        PUSH    BC
        LD      C,FDCFIFO
        OTIR
        POP     BC
l0275:  LD      A,(FDCPARAM)
        OUT     (2AH),A
        OUT     (3EH),A
        LD      A,(LE53B)
        CP      09H
        JR      Z,L028A                 ; (+07h)
        CP      05H
        LD      A,C
        JR      Z,L028C                 ; (+04h)
        JR      L0295                   ; (+0bh)
l028a:  LD      A,C
        ADD     A,A
l028c:  ADD     A,A
        ADD     A,A
        ADD     A,C
l028f:  SUB     1AH
        JR      NC,L028F                ; (-04h)
        ADD     A,1AH
l0295:  INC     A
        OUT     (FDCSEC),A
        LD      A,D
        RES     2,D
        OUT     (FDCCMD),A              ; Floppy Read / Write? Sector
l029d:  JR      L029D                   ; (-02h)
        AND     0DCH
        JR      NZ,L02C7                ; (+24h)
        BIT     5,D
        JR      NZ,L02B6                ; (+0fh)
        LD      A,(FDCPARAM)
        RES     4,A
        OUT     (2AH),A
        OUT     (3EH),A
        PUSH    BC
        LD      C,FDCFIFO
        INIR                            ; Read FDC data to RAM.
        POP     BC
l02b6:  INC     C
        IN      A,(DIPSW)               ; Read DIP switch E.
        BIT     SW_FDCTYPE,A
        LD      A,19H
        JR      NZ,L02C1                ; 8" Floppy
        LD      A,0FH
l02c1:  CP      C
        JR      NC,L025D                ; (-67h)
        XOR     A
        JR      L02EB                   ; (+24h)
l02c7:  BIT     7,A
        LD      A,44H
l02cb:  JR      NZ,L02D6                ; (+09h)
        LD      A,(LE505)
        DEC     A
        LD      (LE505),A
        JR      NZ,L0262                ; (-74h)
l02d6:  JR      NZ,L02DA                ; (+02h)
        LD      A,44H
l02da:  LD      B,A
        LD      HL,(LE449)
        DEC     HL
        LD      A,H
        OR      L
        LD      (LE449),HL
        SCF
        JR      NZ,L02EB                ; (+04h)
        LD      A,B
        OUT     (01H),A
        SCF
l02eb:  RET

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
BSCMD:  LD      A,02H                   ; l 02f7
        LD      (LE434),A
        LD      BC,HDUTILSEND - HDUTILS ; Length of HDC utilities to be copied.
        LD      DE,RAMUTL               ; Destination for HDC utilities at E100h.
        LD      HL,HDUTILS              ; Source of the HDC utilities.
        LDIR                            ; Copy HDC utilities.
        XOR     A
        LD      (LE41D),A               ; 0 to E41DH ?
        LD      A, 10                   ; 10 Sectors in bootstrap
        LD      (TOTSEC),A              ; ...to E539h
        CALL    RAMUTL                  ; Call HDC bootstrap in RAM.
        JR      C,BSCMD                 ; This always succeeds...
        LD      B,00H                   ; Copied by bootstrap into e445.
        LD      DE,0000                 ; Copied by bootstrap into e442-e443
        LD      HL,DISKBUF              ; RAM destination to read boot track into.
        CALL    DISKRD                  ; Read HD Bootstrap from disk.
        JR      C,BSCMD                 ; If it fails, retry forever...

; This part of the bootstrap is common to both floppy and hard disks.
l0322:  LD      BC,0100H                ; Copy one sector
        LD      DE,BOOTSTP              ; ... to C000h
        LD      HL,DISKBUF              ; ... from 8000h
        LDIR                            ; Perform the copy.
        LD      C,20H                   ; Copy boot args, from the second sector of the
        LD      DE,LE520                ; disk to E520h.
        LDIR
        LD      HL,3FD3H                ; Copy the instruction: OUT (3Fh),A
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
HDUTILS: ; l033D
        JR      L0354                   ; E100H
        JR      L0352                   ; E102H
l0341:  DW      FDCISRH                 ; E104H FDC ISR
        JR      L0352                   ; E106H
        JR      HDREAD                  ; E108H HDC Read
        JP      L05C0                   ; E11AH
        NOP
        NOP

; FDC ISR for Hard Disk bootstrap.
; Just clear the status register and re-enable interrupts.
FDCISRH:
        PUSH    AF
        IN      A,(FDCSTAT)             ; FDC Status Register
        POP     AF
        EI
        RET

l0352:  XOR     A
        RET

l0354:  XOR     A
        RET

; Hard Disk Read (L 0356 in ROM, 0E119H in RAM)
; Track in DE
HDREAD: LD      A,(TOTSEC)              ; Copy total number of sectors to read
        LD      (REMSEC),A              ; to E448h.
        LD      A,01H
        LD      (TF_CMD),A
        IN      A,(DIPSW)               ; Read DIP switch E.
        BIT     5,A                     ; Boot drive 0 or 3? Need to test.
        LD      A,00H
        JR      NZ,L0370

        LD      A,07H
        LD      (LE434),A
        LD      A,03H

l0370:  LD      (TF_SA5),A              ; 0 or 3 into E441 depending on DIP Switch. 0 in our case.
        LD      A,B                     ; Store parameter passed into bootstrap in B register into E445h.
        LD      (LE445),A
        LD      (TF_TRKL),DE            ; Store DE parameter into E442
        XOR     A
        LD      (LE444),A

; Read Track
HDRDTRK:
        LD      A,(REMSEC)               ; L 037F
        CP      0AH
        JR      C,L0388
        LD      A,0AH                   ; 10 sectors per track
l0388:  LD      (LE446),A

l038b:  PUSH    HL
        LD      BC,0000
        LD      H,02H
l0391:  IN      A,(HDCSTAT)             ; Hard Disk
        AND     10H
        JR      Z,HDACK                 ; (+0ah)
        DEC     BC
        LD      A,B
        OR      C
        JR      NZ,L0391                ; (-0bh)
        DEC     H
        JR      NZ,L0391                ; (-0eh)
        JR      TOHDRESET               ; (+4bh)

; HD ACK
; Writes byte at 0xE443 to port 0x43 (Track High)
; Writes byte at 0xE442 to port 0x42 (Tracl Low)
; Writes byte at 0xE441 to port 0x41 (SA5, unused?)
; Writes byte at 0xE440 to port 0x40 (HDC Command)
HDACK:  LD      HL,TF_CMD                ; l 03a1
        SET     7,(HL)
        LD      C,43H
        INC     HL
        INC     HL
        INC     HL
        LD      B,04H
l03ad:  LD      A,(HL)
        OUT     (C),A
        DEC     HL
        DEC     C
        DJNZ    L03AD
        LD      BC,0000                 ; Wait for ready for 64k retries.

; HD Retry
HDRETRY:
        IN      A,(HDCSTAT)             ; l 03b7
        AND     3FH
        CP      30H                     ; Indicates HDC is ready
        JR      Z,HDREADY
        DEC     BC                      ; Decrement retry counter
        LD      A,B
        OR      C
        JR      NZ,HDRETRY
        JR      TOHDRESET

; Writes byte @e447 to 0x43     (0x0)   SA3 (Unused?)
; Writes byte @e446 to 0x42     (0xa)   Sector Count
; Writes byte @e445 to 0x41     (0x0)   Head
; Writes byte @e444 to 0x40     (0x0)   Current Sector
HDREADY:                                ; L 03c6
        LD      HL,LE444
        RES     7,(HL)
        LD      C,43H
        INC     HL
        INC     HL
        INC     HL
        LD      B,04H                   ; Loop four times
HDTFLP: LD      A,(HL)                  ; l 03d2
        OUT     (C),A
        DEC     HL
        DEC     C
        DJNZ    HDTFLP

        LD      E,50H
l03db:  LD      HL,0000
l03de:  IN      A,(HDCSTAT)             ; Hard Disk
        AND     10H                     ; HDC Command Ok
        JR      Z,HDCMDOK               ; Now wait for FIFO ready.
        DEC     HL
        LD      A,H
        OR      L
        JR      NZ,L03DE                ; (-0bh)
        DEC     E
        JR      NZ,L03DB                ; (-11h)
TOHDRESET:
        JR      HDRESET                 ; l 03ec
TORDTRACK:
        JR      HDRDTRK                 ; l 03ee
L03F0:
        JR      L038B                   ; (-67h)
TOHDEEXIT:
        JR      HDEEXIT                 ; L 03F2

; HDC Command Accepted, check status.  L03F4
HDCMDOK:
        IN      A,(HDCSTAT)             ; Hard Disk
        AND     0FH                     ; Check lower four bits of status register.
        JR      Z,HDFIFOWAIT            ; Status = 0, OK.
        CP      0AH
        JR      NZ,HDRESET              ; Status != 0x0A, Error.

; Reaches here with either 0 or 0xA in status register lower four bits.
HDFIFOWAIT:
        IN      A,(44H)                 ; Hard Disk
        LD      B,20                    ; Loop 20 times
HDFIFORTY:
        IN      A,(HDCSTAT)             ; Hard Disk
        BIT     7,A                     ; Is FIFO ready?
        JR      Z,RDHDFIFO
        DJNZ    HDFIFORTY
        OUT     (44H),A
        JR      HDRESET

; Read HDC FIFO
RDHDFIFO:                               ; L 040E
        LD      C,48H                   ; FIFO at port 48h.
        POP     HL                      ; Destination RAM address in HL.
        LD      A,(LE446)               ; 0xA, number of sectors to read.
        LD      B,A                     ; Store in B,

RDSECLOOP:                              ; l 0415  
        PUSH    BC                      ; and push onto stack.
        LD      B,00H
        INIR                            ; Read 256 bytes from FIFO at port 48h.
        POP     BC                      ; Pop remaining sector count back into B.
        DJNZ    RDSECLOOP

        OUT     (44H),A                 ; Write number of sectors read into port 0x44, why?
        LD      A,(LE446)               ; Calculate remaining number of sectors to read.
        LD      B,A
        LD      A,(LE444)
        ADD     A,B
        LD      (LE444),A
        LD      A,(REMSEC)
        SUB     B
        LD      (REMSEC),A
        JR      NZ,TORDTRACK
        XOR     A
        JR      HDEXIT                  ; (+09h)

; After a timeout, reset and try again.
HDRESET:
        POP     HL                      ; l 0436
        XOR     A
        OUT     (HDCCMD),A              ; Hard Disk
        OUT     (44H),A                 ; Hard Disk
        OUT     (47H),A                 ; Hard Disk

; HD Error Exit
HDEEXIT:
        SCF                             ; l 043e
; HD Success
HDEXIT: RET                             ; l 043f
HDUTILSEND       EQU $

FDUTILS5:
        XOR     A                       ; LE100
        RET

        JR      L044D                   ; LE102
        DB      0, 0                    ; LE104 FDC ISR (Not used for 5.25" Floppy.)
        JR      L045D                   ; LE106
        JR      L0453                   ; LE108
        JP      L05C0                   ; LE10A

l044d:  LD      A,01H
        LD      (LE41C),A
        RET

l0453:  LD      D,8CH
        BIT     0,B
        JR      Z,L0465                 ; (+0ch)
        SET     1,D
        JR      L0465                   ; (+08h)
l045d:  LD      D,0ACH
        BIT     0,B
        JR      Z,L0465                 ; (+02h)
        SET     1,D
l0465:  LD      C,00H
        PUSH    HL
        LD      HL,LE416
        LD      A,(FDUNIT)
        AND     03H
        ADD     A,L
        LD      L,A
        JR      NC,L0475                ; (+01h)
        INC     H
l0475:  EX      (SP),HL
        POP     IX
        LD      A,(FDUNIT)
        OR      78H
        BIT     5,D
        JR      Z,L0483                 ; (+02h)
        RES     5,A
l0483:  BIT     0,B
        JR      Z,L0489                 ; (+02h)
        SET     2,A
l0489:  LD      B,00H
        OUT     (2AH),A                 ; Write PARAM register
        LD      (FDCPARAM),A
        LD      A,B
        LD      (LE41D),A
l0494:  IN      A,(FDCSTAT)             ; FDC Status Register
        BIT     0,A
        JR      NZ,L0494                ; (-06h)
        BIT     7,A
        JR      NZ,L04F2                ; (+54h)
        LD      A,(LE41C)
        RRA
        JR      NC,L04C1                ; (+1dh)
        LD      A,0CH
        OUT     (FDCCMD),A              ; Write FDC Command Register
        PUSH    BC
        LD      B,0DH
l04ab:  DJNZ    L04AB                   ; (-02h)
        POP     BC
l04ae:  IN      A,(FDCSTAT)             ; FDC Status Register
        BIT     0,A
        JR      NZ,L04AE                ; (-06h)
        BIT     7,A
        LD      A,52H
        JR      NZ,L04F2                ; (+38h)
        XOR     A
        LD      (LE41C),A
        LD      (IX+00H),A
l04c1:  LD      A,(IX+00H)
        OUT     (FDCTRK),A
        LD      A,0AH
l04c8:  DEC     A
        JR      NZ,L04C8                ; (-03h)
        IN      A,(FDCSTAT)             ; FDC Status Register
        BIT     7,A
        LD      A,73H
        JR      NZ,L04F2                ; (+1fh)
        LD      A,E
        LD      (IX+00H),A
        OUT     (FDCDATA),A
        LD      A,0AH
l04db:  DEC     A
        JR      NZ,L04DB                ; (-03h)
        LD      A,1CH
        OUT     (FDCCMD),A              ; Write FDC Command Register
        PUSH    BC
        LD      B,0DH
l04e5:  DJNZ    L04E5                   ; (-02h)
        POP     BC
l04e8:  IN      A,(FDCSTAT)             ; FDC Status Register
        BIT     0,A
        JR      NZ,L04E8                ; (-06h)
        BIT     7,A
        LD      A,53H
l04f2:  JR      NZ,L0540                ; (+4ch)
        BIT     2,D
        JR      NZ,L0504                ; (+0ch)
        PUSH    BC
        LD      B,0FAH
l04fb:  PUSH    BC
        LD      B,19H
l04fe:  DJNZ    L04FE                   ; (-02h)
        POP     BC
        DJNZ    L04FB                   ; (-08h)
        POP     BC
l0504:  LD      A,05H
        LD      (LE505),A
l0509:  PUSH    HL
        LD      A,(FDCPARAM)
        BIT     4,A
        OUT     (2AH),A                 ; Write PARAM register
        PUSH    BC
        LD      A,(FDCPARAM)
        RES     4,A
        OUT     (2AH),A                 ; Write PARAM register
        LD      A,C
        INC     A
        OUT     (FDCSEC),A
        BIT     5,D
        JR      Z,L0544                 ; (+23h)
        LD      A,D
        RES     2,D
        OUT     (FDCCMD),A              ; Write FDC Command Register
        LD      B,0CH
l0528:  DJNZ    L0528                   ; (-02h)
        POP     BC
        PUSH    BC
        LD      C,FDCDATA
        PUSH    DE
        LD      D,02H
l0531:  IN      A,(FDCSTAT)             ; FDC Status Register
        BIT     0,A
        JR      Z,L0561                 ; (+2ah)
        AND     D
        JR      Z,L0531                 ; (-09h)
        OUTI
        JR      NZ,L0531                ; (-0dh)
        JR      L0561                   ; (+21h)
l0540:  JR      L0580                   ; (+3eh)
l0542:  JR      L0509                   ; (-3bh)
l0544:  LD      A,D
        RES     2,D
        OUT     (FDCCMD),A              ; Write FDC Command Register
        LD      B,0CH
l054b:  DJNZ    L054B                   ; (-02h)
        POP     BC
        PUSH    BC
        LD      C,FDCDATA
        PUSH    DE
        LD      D,02H
l0554:  IN      A,(FDCSTAT)             ; FDC Status Register
        BIT     0,A
        JR      Z,L0561                 ; (+07h)
        AND     D
        JR      Z,L0554                 ; (-09h)
        INI
        JR      NZ,L0554                ; (-0dh)
l0561:  IN      A,(FDCSTAT)             ; FDC Status Register
        BIT     0,A
        JR      NZ,L0561                ; (-06h)
        LD      A,B
        POP     DE
        POP     BC
        POP     HL
        OR      A
        JR      NZ,L057C                ; (+0eh)
        AND     0DCH
        JR      NZ,L057C                ; (+0ah)
        INC     H
        LD      A,0FH
        INC     C
        CP      C
        JR      NC,L0504                ; (-75h)
        XOR     A
        JR      L05A0                   ; (+24h)
l057c:  BIT     7,A
        LD      A,44H
l0580:  JR      NZ,L058B                ; (+09h)
        LD      A,(LE505)
        DEC     A
        LD      (LE505),A
        JR      NZ,L0542                ; (-49h)
l058b:  JR      NZ,L058F                ; (+02h)
        LD      A,44H
l058f:  LD      B,A
        LD      HL,(LE449)
        DEC     HL
        LD      A,H
        OR      L
        LD      (LE449),HL
        SCF
        JR      NZ,L05A0                ; (+04h)
        LD      A,B
        OUT     (01H),A
        SCF
l05a0:  RET
FDUTILS5_END    EQU     $

l05a1:  LD      HL,0000
l05a4:  LD      A,(DE)
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

        JR      L05A4                   ; (-1ch)
l05c0:  PUSH    BC
        PUSH    DE
        LD      B,A
        LD      DE,0010H
l05c6:  ADD     HL,HL
        LD      A,D
        RLA
        CP      B
        JR      C,L05CE                 ; (+02h)
        SUB     B
        INC     L
l05ce:  LD      D,A
        DEC     E
        JR      NZ,L05C6                ; (-0ch)
        POP     DE
        POP     BC
        RET

INCMD:  CALL    L061F                   ; 0x05d5
        LD      C,A
        IN      A,(C)
        CALL    L0626
        RET

CICMD:  CALL    L061F                   ; 0x05df
        LD      C,A
l05e3:  IN      A,(C)
        CALL    GETCHAR
        JR      L05E3                   ; (-07h)
OUCMD:  CALL    L061F                   ; l05ea
        LD      C,A
        CALL    L061F
        OUT     (C),A
        RET

COCMD:  CALL    OUCMD
        LD      B,A
l05f8:  CALL    GETCHAR
        OUT     (C),B
        JR      L05F8                   ; (-07h)

FBCMD:  CALL    L061F                   ; 05FFh
        LD      HL,DISKBUF
        LD      (HL),A
        LD      DE,8001H
        LD      BC,DBSIZE
        LDIR
        RET

FICMD:  LD      BC,DBSIZE               ; L 060F
        LD      HL,DISKBUF
        XOR     A
l0616:  LD      (HL),A
        INC     A
        INC     HL
        DEC     C
        JR      NZ,L0616                ; (-06h)
        DJNZ    L0616                   ; (-08h)
        RET

l061f:  CALL    PRSPACE
        CALL    GETBYTE
        RET

l0626:  CALL    PRSPACE
        CALL    L0EE1
        RET

; DD for 8" drives.
DDCMD:  LD      A,SPT8DD                ; 26 sectors
        JR      L0633                   ; (+02h)

SDCMD:  LD      A,SPT8SD                ; 13 sectors
l0633:  LD      (TOTSEC),A
        RET

T0CMD:  CALL    LE102
        RET

; ST for 8" drives.
STCMD:  LD      A,(FDCSTATUS)
        LD      B,A
        LD      HL,L090D
        CALL    L064C
        LD      A,(FDCPARAM)
        LD      B,A
        LD      HL,L0916
l064c:  CALL    L0ED1
        LD      A,B
        CALL    L0626
        RET

H1CMD:  LD      A,01H                   ; 0x0654
        JR      L0659                   ; (+01h)
H0CMD:  XOR     A                       ; 0x0658
l0659:  LD      (FDHEAD),A              ; 0x0659
        RET

USCMD:  CALL    PRSPACE                 ; 0x065d - FD Unit Select
        CALL    L0E6F
        SUB     30H
        LD      HL,L08D2                ; ' - invalid'
        JP      C,MONIT
        CP      04H
        JP      NC,MONIT
        LD      (FDUNIT),A
        RET

RTCMD:  CALL    GETTRK
        CALL    DISKRD
        LD      HL,L08DD                ; ' - disk err'
        JP      C,MONIT
        RET

CRCMD:  CALL    GETTRK
l0684:  CALL    GETCHAR
        PUSH    BC
        PUSH    DE
        PUSH    HL
        CALL    DISKRD
        POP     HL
        POP     DE
        POP     BC
        JR      L0684                   ; (-0eh)

; Read and validate floppy track from console.
GETTRK: LD      B,02H
        LD      HL,LE402
        PUSH    HL
        POP     DE
        CALL    L0E2C
        CALL    L05A1
        LD      A,L                     ; Track < 0
        CP      00H
        LD      HL,L08D2
        JP      C,MONIT                 ; Error, return to monitor.
        CP      4FH                     ; Track >= 79
        JP      NC,MONIT                ; Error, return to monitor.
        LD      E,A
        IN      A,(DIPSW)               ; Read DIP switch E.
        BIT     SW_FDCTYPE,A
        JR      Z,L06BA                 ; 5.25" Drive
        LD      A,E
        CP      4CH
        JP      NC,MONIT
l06ba:  LD      A,(FDHEAD)
        LD      B,A
        LD      HL,DISKBUF
        RET

; RR command for 8" Floppy Drives
RRCMD:  LD      IY,TRKTBL8
        LD      B,4DH
l06c8:  PUSH    BC
        LD      A,(FDHEAD)
        LD      B,A
        LD      E,(IY+00H)
        INC     IY
        LD      A,0DH
        LD      H,00H
        LD      L,E
        CALL    PUTC
        CALL    L0EDC
        LD      HL,DISKBUF
        CALL    DISKRD
        JR      NC,L06E8                ; (+03h)
        CALL    L0ECE
l06e8:  CALL    GETCHAR
        POP     BC
        DJNZ    L06C8                   ; (-26h)
        JR      RRCMD                   ; (-2eh)
        RET

WRCMD:  CALL    GETTRK
        CALL    LE106
        LD      HL,L08DD
        JP      C,MONIT
        RET

CWCMD:  CALL    GETTRK
l0701:  CALL    GETCHAR
        PUSH    BC
        PUSH    DE
        PUSH    HL
        CALL    LE106
        POP     HL
        POP     DE
        POP     BC
        JR      L0701                   ; (-0eh)

DMCMD:  CALL    GETWORD
        LD      B,10H
l0714:  PUSH    BC
        PUSH    HL
        CALL    L0ECE
        POP     HL
        CALL    L0EDC
        CALL    DBLSPC
        LD      B,10H
        PUSH    HL
l0723:  LD      A,(HL)
        CALL    L0EE1
        INC     HL
        DJNZ    L0723                   ; (-07h)
        CALL    DBLSPC
        POP     HL
        LD      B,10H
l0730:  LD      A,(HL)
        CALL    L0EF4
        INC     HL
        DJNZ    L0730                   ; (-07h)
        POP     BC
        DJNZ    L0714                   ; (-26h)
        RET

SMCMD:  CALL    PRSPACE                 ; L 073B
        CALL    GETWORD
l0741:  LD      A,(HL)
        CALL    L0626
        CALL    PRSPACE
        CALL    L0E6F
        CP      20H
        JR      Z,L075D                 ; (+0eh)
        LD      B,00H
        PUSH    HL
        LD      HL,L0759
        EX      (SP),HL
        CALL    L0E5C
L0759:  CALL    L0E51
        LD      (HL),A
l075d:  INC     HL
        PUSH    HL
        CALL    L0ECE
        POP     HL
        CALL    L0EDC
        JR      L0741                   ; (-27h)

; Loop through all SIO ports 
SICMD:  LD      C,01H                   ; l0768
l076a:  IN      A,(C)
        OUT     (C),A
        INC     C
        INC     C
        LD      A,C
        CP      15H
        JR      C,L076A                 ; (-0bh)
        CALL    GETCHAR                 ; Process character
        JR      SICMD                   ; (-12h)

; Obtain console on IBC DISK SLAVE
SECMD:  LD      HL,0000                ; 0x077a
l077d:  CALL    RDHDCSTAT
        AND     30H
        JR      Z,L0798                 ; (+14h)
        DEC     HL
        LD      A,H
        OR      L
        JR      NZ,L077D                ; (-0ch)
        LD      HL,L078F
        JP      MONIT
L078F:  DB      08H
        DB      ' Timeout'

l0798:  LD      A,0AH
        SET     7,A
        OUT     (HDCCMD),A              ; Write Hard Disk Register
l079e:  CALL    RDHDCSTAT
        XOR     30H
        AND     30H
        JR      NZ,L079E                ; (-09h)
        XOR     A
        OUT     (HDCCMD),A
l07aa:  CALL    RDHDCSTAT
        BIT     5,A
        JR      NZ,L07AA                ; (-07h)
        LD      C,02H
        LD      A,C
        OUT     (HDCCMD),A

l07b6:  BIT     0,C
        JR      NZ,L07C9                ; (+0fh)
        IN      A,(00H)
        AND     01H
        JR      Z,L07C9                 ; (+09h)
        IN      A,(01H)
        OUT     (41H),A
        SET     0,C
        LD      A,C
        OUT     (HDCCMD),A
l07c9:  CALL    RDHDCSTAT
        BIT     4,A
        JR      NZ,L07FB                ; (+2bh)
        AND     0FH
        LD      B,A
        SET     2,C
        RES     1,C
        LD      A,C
        OUT     (HDCCMD),A
l07da:  CALL    RDHDCSTAT
        BIT     4,A
        JR      Z,L07DA                 ; (-07h)
        SLA     A
        SLA     A
        SLA     A
        SLA     A
        OR      B
        LD      B,A
        SET     1,C
        RES     2,C
        LD      A,C
        OUT     (HDCCMD),A
l07f2:  IN      A,(00H)
        AND     02H
        JR      Z,L07F2                 ; (-06h)
        LD      A,B
        OUT     (01H),A
l07fb:  CALL    RDHDCSTAT
        BIT     5,A
        JR      Z,L07B6                 ; (-4ch)
        RES     0,C
        LD      A,C
        OUT     (HDCCMD),A
l0807:  CALL    RDHDCSTAT
        BIT     5,A
        JR      NZ,L0807                ; (-07h)
        JR      L07B6                   ; (-5ah)

; Read HDC Status and make sure two consecutive reads are consistent.
RDHDCSTAT:
        PUSH    BC
        IN      A,(HDCSTAT)
l0813:  LD      B,A
        IN      A,(HDCSTAT)
        CP      B
        JR      NZ,L0813                ; (-06h)
        POP     BC
        RET

GOCMD:  CALL    GETWORD                 ; L 081B
        JP      (HL)

L081F:  DB      6EH, 08H

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

CMDTBL8:
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
        DB      'SE'
        DW      SECMD
        DB      'GO'
        DW      GOCMD

L08D2:  DB      0AH
        DB      ' - invalid'
L08DD:  DB      0BH
        DB      ' - disk err'
L08E9:  DB      10H
        DB      ' - restore/seek error'
L08FF:  DB      0DH
        DB      ' - read error'
L090D:  DB      08H
        DB      'STATUS -'
L0916:  DB      08H
        DB      ' PARAM -'

DDCMD5: LD      A,SPT5                  ; DD for 5.25" drives.
        LD      (TOTSEC),A
        RET

STCMD5:  IN      A,(FDCSTAT)            ; ST for 5.25" drives.
        LD      B,A
        LD      HL,L0A55
        CALL    L0935
        LD      A,(FDCPARAM)
        LD      B,A
        LD      HL,L0A5C
l0935:  CALL    L0ED1
        LD      A,B
        CALL    L0626
        RET

RRCMD5:  LD      IY,TRKTBL5              ; RR for 5.25" drives.
        LD      B,50H
l0943:  PUSH    BC
        LD      A,(FDHEAD)
        LD      B,A
        LD      E,(IY+00H)
        INC     IY
        LD      A,0DH
        LD      H,00H
        LD      L,E
        CALL    PUTC
        CALL    L0EDC
        LD      HL,DISKBUF
        CALL    DISKRD
        JR      NC,L0963                ; (+03h)
l0960:  CALL    L0ECE
l0963:  CALL    GETCHAR
        POP     BC
        DJNZ    L0943                   ; (-26h)
l0969:  JR      RRCMD5                   ; (-2eh)
        RET

L096C:  DB      0BEH, 09H

; 80-track floppy
TRKTBL5:
        DB      4FH, 27H, 4EH, 26H, 4DH, 25H, 4CH, 24H, 4BH, 23H, 4AH, 22H, 49H, 21H, 48H, 20H
        DB      47H, 1FH, 46H, 1EH, 45H, 1DH, 44H, 1CH, 43H, 1BH, 42H, 1AH, 41H, 19H, 40H, 18H
        DB      3FH, 17H, 3EH, 16H, 3DH, 15H, 3CH, 14H, 3BH, 13H, 3AH, 12H, 39H, 11H, 38H, 10H
        DB      37H, 0FH, 36H, 0EH, 35H, 0DH, 34H, 0CH, 33H, 0BH, 32H, 0AH, 31H, 09H, 30H, 08H
        DB      2FH, 07H, 2EH, 06H, 2DH, 05H, 2CH, 04H, 2BH, 03H, 2AH, 02H, 29H, 01H, 28H, 00H

CMDTBL5:
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
        DW      DDCMD5
        DB      'T0'
        DW      T0CMD
        DB      'ST'
        DW      STCMD5
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
        DW      RRCMD5
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
        DB      'SE'
        DW      SECMD

L0A1A:  DB      INVSTRLEN
        DB      ' - invalid'
INVSTRLEN EQU   $ - L0A1A - 1        
L0A25:  DB      DESTRLEN
        DB      ' - disk err'
DESTRLEN EQU    $ - L0A25 - 1
L0A31:  DB      10H     ; This is a bug in the orignal ROM, should be SESTRLEN
        DB      ' - restore/seek error'
SESTRLEN EQU    $ - L0A31 - 1
L0A47:  DB      RESTRLEN
        DB      ' - read error'
RESTRLEN EQU    $ - L0A47 - 1
L0A55:  DB      ATUSTRLEN
        DB      'ATUS -'
ATUSTRLEN EQU $ - L0A55 - 1
L0A5C:  DB      PARSTRLEN
        DB      ' PARAM -'
PARSTRLEN EQU $ - L0A5C - 1

; Entry if DIP SW E bit 2 is set:
RAMTEST:
        LD      A,03H                   ; Reset UART 1
        OUT     (00H),A
        LD      A,11H                   ; Set baud rate to 38400,n,8,1
        OUT     (00H),A

        LD      IY,L0A74
        JP      OUTCRLF
l0a74:  LD      IY,L0A7E
        LD      DE,L0BF8                ; 'IBC MIDDI-CADET Memory Test'
        JP      OUTSTRQ
L0A7E:  IN      A,(01H)
        AND     7FH
        CP      41H
        JR      Z,L0A8E                 ; (+08h)
        CP      30H
l0a88:  JR      C,L0A74                 ; (-16h)
        CP      32H
        JR      NC,L0A74                ; (-1ah)
l0a8e:  EXX
        LD      C,A
        EXX
l0a91:  LD      IY,L0A9B
        LD      DE,L0C73                ; 'which bank to select (0-9 or A<all>)? '
        JP      OUTSTRQ
L0A9B:  IN      A,(01H)
        AND     7FH
        CP      41H
        JR      Z,L0AAB                 ; (+08h)
        CP      30H
        JR      C,L0A91                 ; (-16h)
        CP      3AH
        JR      NC,L0A91                ; (-1ah)
l0aab:  EXX
        LD      L,A
        EXX
        EXX
l0aaf:  LD      B,30H
        EXX
l0ab2:  EXX
        LD      A,B
        CP      3AH
l0ab6:  JP      Z,L0A74
        LD      A,L
        CP      41H
        JR      Z,L0ABF                 ; (+01h)
l0abe:  CP      B
l0abf:  EXX
        JP      NZ,L0B89
        LD      IY,L0ACD
        LD      DE,L0C9C                ; 'Bank'
        JP      OUTSTR
L0ACD:  EXX
        LD      A,B
        EXX
        LD      IX,0AD7H
        JP      OUTCHR
        EXX
        LD      A,B
        EXX
; 0x0ADA: Bank select register
        OUT     (38H),A
        LD      A,01H
        LD      (4001H),A
        LD      (4002H),A
        LD      A,(4001H)
        CP      01H
        JR      Z,L0AFC                 ; (+11h)
        LD      A,(4002H)
        CP      01H
        JR      Z,L0AFC                 ; (+0ah)
        LD      IY,L0B89
        LD      DE,L0CA4                ; ' not found '
        JP      OUTSTR
l0afc:  EXX
        LD      A,C
        EXX
        CP      31H
        JR      Z,L0B1E                 ; (+1bh)
        LD      C,00H
l0b05:  LD      IY,L0B0C
        JP      L0B90
L0B0C:  LD      IY,L0B13
        JP      OUTPERIOD
L0B13:  INC     C
        JR      NZ,L0B05                ; (-11h)
        EXX
        LD      A,C
        EXX
        CP      41H
        JP      NZ,L0B89
l0b1e:  LD      C,00H
        LD      IY,L0B27
        JP      L0B90
L0B27:  LD      IY,L0B35
        LD      A,64H
        LD      I,A
        LD      DE,L0D07                ; 'Now entering Row/Column sensitivity tests'
        JP      OUTSTR

L0B35:  LD      HL,2000H
l0b38:  LD      DE,2000H
        LD      (HL),0FFH
l0b3d:  LD      A,D
        OR      E
        JR      Z,L0B64                 ; (+23h)
        LD      A,D
        CP      H
        JR      NZ,L0B49                ; (+04h)
        LD      A,E
        CP      L
        JR      Z,L0B55                 ; (+0ch)
l0b49:  LD      A,(DE)
        LD      C,00H
        LD      B,A
        CP      C
        LD      IY,L0B55
        JP      NZ,L0D35
l0b55:  LD      A,E
        OR      A
        JR      Z,L0B60                 ; (+07h)
        RLA
        LD      E,A
        JR      NC,L0B3D                ; (-20h)
        INC     D
        JR      L0B3D                   ; (-23h)
l0b60:  LD      E,01H
        JR      L0B3D                   ; (-27h)
l0b64:  LD      B,(HL)
        LD      A,0FFH
        LD      C,A
        CP      B
        LD      IY,L0B70
        JP      NZ,L0DA4
L0B70:  LD      A,I
        DEC     A
        LD      I,A
        LD      A,64H
        JR      NZ,L0B82                ; (+09h)
        LD      I,A
        LD      IY,L0B82
        JP      OUTPERIOD
l0b82:  LD      (HL),00H
        INC     HL
        LD      A,H
        OR      L
        JR      NZ,L0B38                ; (-51h)
l0b89:  EXX
        INC     B
        INC     H
        EXX
        JP      L0AB2
l0b90:  LD      HL,1FFFH
l0b93:  INC     HL
        LD      (HL),C
        LD      A,H
        OR      L
        JR      NZ,L0B93                ; (-06h)
        LD      HL,2000H
l0b9c:  LD      A,(HL)
        LD      B,A
        CP      C
        JR      NZ,L0BA8                ; (+07h)
        INC     HL
        LD      A,H
        OR      L
        JR      NZ,L0B9C                ; (-0ah)
        JP      (IY)
l0ba8:  LD      IY,L0B89
        JP      L0DA4

; Print 0-terminated strint pointed to by DE and read a character from the SIO.
; Return address in IY
OUTSTRQ:
        LD      IX,L0BB3                ; L0BAF
L0BB3:  LD      A,(DE)
        INC     DE
        OR      A
        JR      NZ,OUTCHR               ; String is not empty, print it.
WAITCH: IN      A,(SIO0S)
        AND     01H
        JR      Z, WAITCH               ; Wait for character available.
        IN      A,(SIO0D)               ; Read character from SIO
        OUT     (SIO0D),A               ; ... and echo it.
        JP      OUTCRLF

; Print 0-terminated strint pointed to by DE.
; Return address in IY
OUTSTR: LD      IX,L0BC9                ; L 0BC5
L0BC9:  LD      A,(DE)
        INC     DE
        OR      A
        JR      NZ,OUTCHR
        JP      (IY)                    ; Return

; Output a character in A to the SIO.
OUTCHR: EX      AF,AF'                  ; L 0BD0
l0bd1:  IN      A,(SIO0S)
        AND     02H
        JR      Z,L0BD1                 ; Wait for transmit ready
        EX      AF,AF'
        OUT     (SIO0D),A               ; Write character to SIO
        JP      (IX)

; Output a CR/LF to the SIO.
OUTCRLF:
        LD      A, CR                   ; L 0BDC
        LD      IX,L0BE4
        JR      OUTCHR                  ; Output CR
L0BE4:  LD      A, LF
        LD      IX,L0BEC
        JR      OUTCHR
L0BEC:  JP      (IY)                    ; Return

; Output a period to the SIO.
OUTPERIOD:
        LD      A, '.'                  ; l 0bee
        LD      IX,L0BF6
        JR      OUTCHR
L0BF6:  JP      (IY)                    ; Return

L0BF8:  DB      CR, LF, 'IBC MIDDI-CADET Memory Test'
        DB      CR, LF, 'test # 0 - cell test'
        DB      CR, LF, 'test # 1 - row/column sensitivity test'
        DB      CR, LF, 'select test (0,1 or A<all>)? ', 0
L0C73:  DB      CR, LF, 'which bank to select (0-9 or A<all>)? ', 0
L0C9C:  DB      CR, LF, 'Bank ', 0
L0CA4:  DB      '  not found ', CR, LF, 0
L0CB3:  DB      CR, LF, 'ERBC address=', 0
L0CC3:  DB      '; Read=', 0
L0CCB:  DB      '; Expected=', 0
L0CD7:  DB      '; Test cell address=', 0
L0CEC:  DB      '; Pattern=', 0
L0CF7:  DB      CR, LF, 'ERTC address=', 0
L0D07:  DB      CR, LF, 'Now entering Row/Column sensitivity tests', CR, LF, 0

l0d35:  EXX
        LD      SP,IY
        LD      IY,L0D42
        LD      DE,L0CB3                ; 'ERBC address='
l0d3f:  JP      OUTSTR
l0d42:  EXX
        LD      IY,L0D4A
        JP      L0DEE
L0D4A:  EXX
        LD      IY,L0D55
        LD      DE,L0CC3
        JP      OUTSTR
L0D55:  EXX
        LD      A,B
        LD      IY,L0D5E
        JP      L0DDA
L0D5E:  EXX
        LD      DE,L0CCB
        LD      IY,L0D69
        JP      OUTSTR
l0d69:  EXX
        LD      A,C
        LD      IY,L0D72
        JP      L0DDA
L0D72:  EXX
l0d73:  LD      DE,L0CD7
        LD      IY,L0D7D
        JP      OUTSTR
L0D7D:  EXX
        EX      DE,HL
        LD      IY,L0D86
        JP      L0DEE
L0D86:  EX      DE,HL
        EXX
        LD      IY,L0D92
        LD      DE,L0CEC
        JP      OUTSTR
L0D92:  EXX
        LD      IY,L0D9B
        LD      A,C
        JP      L0DDA
L0D9B:  LD      IY,0000
        ADD     IY,SP
        JP      OUTCRLF
l0da4:  EXX
        LD      SP,IY
        LD      IY,L0DB1
        LD      DE,L0CF7                ; 'ERTC address='
        JP      OUTSTR
L0DB1:  EXX
        EX      DE,HL
        LD      IY,L0DBA
        JP      L0DEE
L0DBA:  EX      DE,HL
        EXX
        LD      IY,L0DC6
        LD      DE,L0CC3
        JP      OUTSTR
L0DC6   EXX
        LD      A,B
        LD      IY,L0DCF
        JP      L0DDA
L0DCF:  EXX
        LD      IY,L0D92
        LD      DE,L0CCB
        JP      OUTSTR
l0dda:  EXX
        LD      B,A
        RRA
        RRA
        RRA
        RRA
        LD      HL,L0DE5
        JR      L0E1C                   ; (+37h)
L0DE5:  LD      A,B
        LD      HL,L0DEB
        JR      L0E1C                   ; (+31h)
L0DEB:  EXX
        JP      (IY)
l0dee:  LD      A,D
        EXX
        RRA
        RRA
        RRA
        RRA
        LD      HL,L0DFA
        JP      L0E1C
L0DFA:  EXX
        LD      A,D
        EXX
        LD      HL,L0E03
        JP      L0E1C
L0E03:  EXX
        LD      A,E
        EXX
        LD      HL,L0E10
        RRA
        RRA
        RRA
        RRA
        JP      L0E1C
L0E10:  EXX
        LD      A,E
        EXX
        LD      HL,L0E19
        JP      L0E1C
L0E19:  EXX
        JP      (IY)
l0e1c:  AND     0FH
        ADD     A,90H
        DAA
        ADC     A,40H
        DAA
        LD      IX,L0E2B
        JP      OUTCHR

L0E2B:  JP      (HL)
l0e2c:  CALL    PRSPACE
l0e2f:  CALL    L0E6F
        CP      0DH
        JR      Z,L0E42                 ; (+0ch)
        CP      08H
        JR      NZ,L0E3E                ; (+04h)
        INC     B
        DEC     HL
        JR      L0E2F                   ; (-0fh)
l0e3e:  LD      (HL),A
        INC     HL
        DJNZ    L0E2F                   ; (-13h)
l0e42:  XOR     A
        LD      (HL),A
        RET

; Read Hex 16 bits from Console into HL
GETWORD: CALL   GETBYTE
        LD      H,A
        CALL    GETBYTE
        LD      L,A
        RET

; Read Hex Byte from Console into A
GETBYTE: CALL    L0E55                   ; l 0e4e
l0e51:  RLA
        RLA
        RLA
        RLA
l0e55:  PUSH    BC
        AND     0F0H
        LD      B,A
        CALL    L0E6F
l0e5c:  SUB     30H
        JR      C,L0EA2                 ; (+42h)
        CP      0AH
        JR      C,L0E6C                 ; (+08h)
        SUB     07H
        JR      C,L0EA2                 ; (+3ah)
        CP      10H
        JR      NC,L0EA2                ; (+36h)
l0e6c:  OR      B
        POP     BC
        RET

l0e6f:  CALL    CONSTAT
        JR      Z,L0E6F                 ; (-05h)
        CALL    GETCHAR
        RET

; Check if character is available from the console.
CONSTAT:  LD    A,(SIOBASE)
        PUSH    BC
        LD      C,A
        IN      A,(C)
        BIT     0,A
        POP     BC
        RET

; GETCHAR - Read character from Console, return to Monitor if ESC.
GETCHAR:  PUSH    BC
        CALL    CONSTAT
        JR      Z,L0EA0                 ; (+17h)
        LD      A,(SIOBASE)             ; Base of SIO (Status)
        INC     A                       ; SIO Data Port
        LD      C,A
        IN      A,(C)                   ; Read from SIO Data Port
        AND     7FH                     ; 7-bit ASCII
        CP      'a'                     ; Check if lower case.
        JR      C,L0E98                 ; Already upper case.
        RES     5,A                     ; Convert to upper case.
l0e98:  CP      1BH                     ; If ESC,
        JP      Z,REINIT                ; ... return to monitor.
        CALL    PUTC                    ; Echo the character to the console
l0ea0:  POP     BC
        RET

l0ea2:  LD      HL,L08D2                ; ' - invalid'
MONIT:  CALL    L0ED1                   ; 0xl0ea5
REINIT: LD      SP,STKTOP
        JP      L00D9                   ; Signon and command prompt.

; The following code runs if there is an NMI.  The purpose is to
; test the RAM in the machine.  As such, no RAM variables or stack
; are utilized.  Instead, registers are used to hold all state.
;
; Memory Parity Error, do RAM test...
PARERR: LD      DE,PERRSTR                ; l0f1b:  DS      'Memory Parity Error!!! (ESC or M)', 07H, 0
        LD      IY,L0EB8
        JP      OUTSTR

l0eb8:  IN      A,(00H)
        AND     01H
        JR      Z,L0EB8                 ; (-06h)
        IN      A,(01H)
        AND     5FH
        CP      1BH                      ; ESC, reset to 0.
        JP      Z,START
        CP      'M'                     ; 'M'
        JP      Z,RAMTEST
        JR      PARERR
l0ece:  LD      HL,PROMPT               ; 0x0F3e
l0ed1:  PUSH    BC                      ; Print string, count is in first byte,
        LD      B,(HL)
l0ed3:  INC     HL
        LD      A,(HL)
        CALL    PUTC
        DJNZ    L0ED3                   ; (-07h)
        POP     BC
        RET

l0edc:  LD      A,H
        CALL    L0EE1
        LD      A,L
l0ee1:  PUSH    AF
        RRA
        RRA
        RRA
        RRA
        CALL    L0EEA
        POP     AF
l0eea:  AND     0FH
        ADD     A,30H
        CP      3AH
        JR      C,L0EF4                 ; (+02h)
        ADD     A,07H
l0ef4:  CP      20H
        JR      C,L0EFC                 ; (+04h)
        CP      80H
        JR      C,PUTC
l0efc:  LD      A,2EH
PUTC:   PUSH    BC                      ; 0x0efe
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

DBLSPC: CALL    PRSPACE                 ; 0x0F10: Print two spaces
PRSPACE:
        PUSH    AF                      ; 0x0F13: Print space
        LD      A,20H
        CALL    PUTC
        POP     AF
        RET
PERRSTR:
        DB      'Memory Parity Error!!! (ESC or M)', 07H, 0     ; 0x0F1B
PROMPT: DB      03, CR, LF, '*' ; 0x0F3E
