# IBC/Integrated Business Computers - MultiStar


## IBC MultiStar* SERIES   Loader PROM  V3.4

To get into the Loader PROM monitor, set DIP Switch E position 1 to ON, and press ESC on any one of the 10 serial ports.  Signs on with:


```
IBC MultiStar* SERIES   Loader PROM  V3.4
*
```

<table>
  <tr>
   <td>

<strong><em>Command</em></strong>
   </td>
   <td><strong><em>Argument</em></strong>
   </td>
   <td><strong><em>Description</em></strong>
   </td>
   <td><strong><em>Notes</em></strong>
   </td>
  </tr>
  <tr>
   <td>IN
   </td>
   <td>&lt;port>
   </td>
   <td>Input from Port
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>OU
   </td>
   <td>&lt;port> &lt;data>
   </td>
   <td>Output to Port
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>CI
   </td>
   <td>&lt;port>
   </td>
   <td>Continuous Input
   </td>
   <td>Continuous read from I/O port until ESC is pressed.
   </td>
  </tr>
  <tr>
   <td>CO
   </td>
   <td>&lt;port>
   </td>
   <td>Continuous Output
   </td>
   <td>Continuous write to I/O port until ESC is pressed.
   </td>
  </tr>
  <tr>
   <td>FB
   </td>
   <td>&lt;fillbyte>
   </td>
   <td>Fill Buffer
   </td>
   <td>Fills memory from 8000-9A00 with specified byte.
   </td>
  </tr>
  <tr>
   <td>FI
   </td>
   <td>none
   </td>
   <td>Fill Incrementing
   </td>
   <td>Fills memory from 8000-9A00 with an incrementing pattern 0-255.
   </td>
  </tr>
  <tr>
   <td>DD
   </td>
   <td>none
   </td>
   <td>Double Density
   </td>
   <td>Sets sectors per track to 26 for 8” and 16 for 5.25” (DIP Switch setting.)
   </td>
  </tr>
  <tr>
   <td>SD
   </td>
   <td>none
   </td>
   <td>Single Density
   </td>
   <td>Sets sectors per track to 26.
<p>
Available only with 8” Disk Drive DIP Switch setting.
   </td>
  </tr>
  <tr>
   <td>T0
   </td>
   <td>none
   </td>
   <td>CALL 0E102h:
<p>
Writes 1 to 0E41Ch
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>ST
   </td>
   <td>none
   </td>
   <td>Status
   </td>
   <td>Returns FDC Status from 1795 and PARAM register from 0x2A.
   </td>
  </tr>
  <tr>
   <td>H1
   </td>
   <td>none
   </td>
   <td>Head 1
   </td>
   <td>Select Floppy Head 1
<p>
Writes 1 to 0E420h
   </td>
  </tr>
  <tr>
   <td>H0
   </td>
   <td>none
   </td>
   <td>Head 0
   </td>
   <td>Select Floppy Head 0
<p>
Writes 0 to 0E420h
   </td>
  </tr>
  <tr>
   <td>US
   </td>
   <td>&lt;0,1,2,3>
   </td>
   <td>Unit Select
   </td>
   <td>Floppy Drive Select: 0-3
   </td>
  </tr>
  <tr>
   <td>RT
   </td>
   <td>&lt;track>
   </td>
   <td>Read Floppy Track
   </td>
   <td>Track range: 0-78
   </td>
  </tr>
  <tr>
   <td>CR
   </td>
   <td>&lt;track>
   </td>
   <td>Continuous Read Floppy Track
   </td>
   <td>Track range: 0-78
   </td>
  </tr>
  <tr>
   <td>RR
   </td>
   <td>none
   </td>
   <td>
   </td>
   <td>Read (verify) different floppy tracks, press ESC to stop.
   </td>
  </tr>
  <tr>
   <td>WR
   </td>
   <td>&lt;track>
   </td>
   <td>Write floppy sector
   </td>
   <td>Track range: 0-78
   </td>
  </tr>
  <tr>
   <td>CW
   </td>
   <td>&lt;track>
   </td>
   <td>Continuous Write
   </td>
   <td>Track range: 0-78
   </td>
  </tr>
  <tr>
   <td>DM
   </td>
   <td>&lt;addr>
   </td>
   <td>Display Memory
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>SM
   </td>
   <td>&lt;addr> &lt;data>
   </td>
   <td>Set memory
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>BF
   </td>
   <td>none
   </td>
   <td>Boot Floppy
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>BS
   </td>
   <td>none
   </td>
   <td>Boot SMD Hard Disk
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>SI
   </td>
   <td>none
   </td>
   <td>Set SIO?
   </td>
   <td>Allows the user to choose another UART by pressing ESC.
   </td>
  </tr>
  <tr>
   <td>SE
   </td>
   <td>none
   </td>
   <td>Hard Disk Diags
   </td>
   <td>IBC DIAGNOSTICS - DISK SLAVE V4.0
   </td>
  </tr>
  <tr>
   <td>GO
   </td>
   <td>&lt;addr>
   </td>
   <td>Start execution at address.
   </td>
   <td>Available only with 8” Disk Drive DIP Switch setting.
   </td>
  </tr>
</table>



### Memory Test

The loader PROM contains a RAM memory test, which is invoked in any of the following ways:



1. In case of an NMI interrupt.
2. Setting DIP Switch E position 3 to ON.
3. Using the “GO0066” monitor command to jump to the NMI vector address. 

The memory test signs on with:


```
Memory Parity Error!!! (ESC or M)

IBC MIDDI-CADET Memory Test
test # 0 - cell test
test # 1 - row/column sensitivity test
select test (0,1 or A<all>)? A

which bank to select (0-9 or A<all>)? A
```



### Important memory locations:

0xE100 - Floppy and hard disk bootstraps are copied from ROM to here.  The second stage loader read from disk will use jump table entry points here to do disk reads.

0xE400 - FDC Param (string@ 0916h) (copy of register at 0x2A)

0xE401 - FDC Status (string@ 090Dh)

0xE415 - Floppy Drive Unit 0-3 (maybe hard drive too?)

0xE41C - Written by T0 command.

0xE420 - Written by the H0/1 command.

0xE539 - Set to 0x10 by the DD command.

0x8000-0x9A00 - Memory buffer used for Disk I/O (26 sectors of 128 bytes each.)  This is enough for one track worth of data.


## IBC DIAGNOSTICS - DISK SLAVE V4.0


<table>
  <tr>
   <td><strong><em>Command</em></strong>
   </td>
   <td><strong><em>Argument</em></strong>
   </td>
   <td><strong><em>Description</em></strong>
   </td>
   <td><strong><em>Notes</em></strong>
   </td>
  </tr>
  <tr>
   <td>IN
   </td>
   <td>&lt;port>
   </td>
   <td>Input from Port
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>OU
   </td>
   <td>&lt;port> &lt;data>
   </td>
   <td>Output to Port
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>CI
   </td>
   <td>&lt;port>
   </td>
   <td>Continuous Input
   </td>
   <td>Continuous read from I/O port until ESC is pressed.
   </td>
  </tr>
  <tr>
   <td>CO
   </td>
   <td>&lt;port> &lt;data>
   </td>
   <td>Continuous Output
   </td>
   <td>Continuous write to I/O port until ESC is pressed.
   </td>
  </tr>
  <tr>
   <td>FB
   </td>
   <td>&lt;addr> &lt;byte>
   </td>
   <td>Fill Buffer
   </td>
   <td>Fills memory with specified byte.
   </td>
  </tr>
  <tr>
   <td>FI
   </td>
   <td>&lt;addr>
   </td>
   <td>Fill Incrementing
   </td>
   <td>Fills memory with an incrementing pattern 0-255.
   </td>
  </tr>
  <tr>
   <td>WI
   </td>
   <td>&lt;hh> &lt;cccc> &lt;ss>
   </td>
   <td>Write Incrementing
   </td>
   <td>Write Incrementing Pattern to disk at &lt;hh> &lt;cccc> &lt;ss> (Must be formatted.)
   </td>
  </tr>
  <tr>
   <td>DM
   </td>
   <td>&lt;addr>
   </td>
   <td>Display Memory
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>SM
   </td>
   <td>&lt;addr> &lt;data>
   </td>
   <td>Set memory
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>RD
   </td>
   <td>&lt;head> &lt;track> &lt;sector>
   </td>
   <td>Read Disk
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>WR
   </td>
   <td>&lt;head> &lt;track> &lt;sector> &lt;data>
   </td>
   <td>Write Disk
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>HM
   </td>
   <td>none
   </td>
   <td>Home
   </td>
   <td>Homes drives 0,1
   </td>
  </tr>
  <tr>
   <td>SL
   </td>
   <td>
   </td>
   <td>
   </td>
   <td>Echoes characters to the serial port until ESC is pressed.
   </td>
  </tr>
  <tr>
   <td>F0
   </td>
   <td>none
   </td>
   <td>Format Track 0?
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>FM
   </td>
   <td>&lt;head>
   </td>
   <td>Format Disk
   </td>
   <td>Nn appears to affect sector size.
<p>
00 or 01 = 256
<p>
02 or 03 = 512
<p>
04 or 05 = 1024
<p>
06 or 07 = 128
   </td>
  </tr>
  <tr>
   <td>ID
   </td>
   <td>&lt;head> &lt;track>
   </td>
   <td>Read ID
   </td>
   <td>A1FE020018A1F8
   </td>
  </tr>
  <tr>
   <td>CA
   </td>
   <td>none
   </td>
   <td>Calls 011DH in a loop until ESC is pressed.
   </td>
   <td>Press ESC to exit
   </td>
  </tr>
  <tr>
   <td>SC
   </td>
   <td>&lt;drive>
   </td>
   <td>Set Configuration
   </td>
   <td>Sets heads, tracks, wpc (in HEX)
<p>
Ie:
<p>
SC 00
<p>
04
<p>
0267
<p>
1000
   </td>
  </tr>
  <tr>
   <td>BU
   </td>
   <td>&lt;aa> &lt;bbbb> &lt;cccc>
   </td>
   <td>(Tape)
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>RS
   </td>
   <td>&lt;aa> &lt;bbbb> &lt;cccc>
   </td>
   <td>Read Status?
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>GL
   </td>
   <td>
   </td>
   <td>(Tape)
   </td>
   <td>Hangs
   </td>
  </tr>
  <tr>
   <td>DU
   </td>
   <td>
   </td>
   <td>(Disk/Tape)
   </td>
   <td>Hangs
   </td>
  </tr>
  <tr>
   <td>RT
   </td>
   <td>
   </td>
   <td>Read Tape?
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>WT
   </td>
   <td>
   </td>
   <td>Write Tape?
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>RW
   </td>
   <td>
   </td>
   <td>Rewind Tape?
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>US
   </td>
   <td>&lt;nn>
   </td>
   <td>Unit Select
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>QC
   </td>
   <td>&lt;drive> &lt;0-0C>
   </td>
   <td>Set Drive Parameters
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>DS
   </td>
   <td>none
   </td>
   <td>Disk Seek
   </td>
   <td>Seeks from the current cyl to 0, and back to the original cyl.
   </td>
  </tr>
  <tr>
   <td>TM
   </td>
   <td>
   </td>
   <td>(Tape)
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>NE
   </td>
   <td>none
   </td>
   <td>
   </td>
   <td>Writes 0 to 2D18H
   </td>
  </tr>
  <tr>
   <td>XT
   </td>
   <td>none
   </td>
   <td>eXiT
   </td>
   <td>SP=3000H and Reinit (hangs)
   </td>
  </tr>
  <tr>
   <td>SV
   </td>
   <td>
   </td>
   <td>
   </td>
   <td>
   </td>
  </tr>
</table>



## I/O Ports


<table>
  <tr>
   <td><strong><em>I/O Port Range</em></strong>
   </td>
   <td><strong><em>Description</em></strong>
   </td>
  </tr>
  <tr>
   <td>0x00-0x13
   </td>
   <td>UART1-10
   </td>
  </tr>
  <tr>
   <td>0x14
   </td>
   <td>Timer Tick?
<p>
Read = Clear Interrupt/Disable
<p>
Write = Countdown (written to 0xfe)
   </td>
  </tr>
  <tr>
   <td>0x18
   </td>
   <td>Z8530 BISYNC
   </td>
  </tr>
  <tr>
   <td>0x20
   </td>
   <td>RAM Parity Enable (Bit 0) (MultiStar)
   </td>
  </tr>
  <tr>
   <td>0x24-0x27
   </td>
   <td>WD1795 FDC Controller
   </td>
  </tr>
  <tr>
   <td>0x28
   </td>
   <td>FDC Data FIFO
   </td>
  </tr>
  <tr>
   <td>0x29
   </td>
   <td>?
   </td>
  </tr>
  <tr>
   <td>0x2A
   </td>
   <td>FDC PARAM register
   </td>
  </tr>
  <tr>
   <td>0x38
   </td>
   <td>Bank Select (0x3n, where n is bank 0-9)
<p>
Common area 0x0000-0x3FFF
   </td>
  </tr>
  <tr>
   <td>0x3C
   </td>
   <td>DIP Switch E
   </td>
  </tr>
  <tr>
   <td>0x3E
   </td>
   <td>FDC FIFO Control?
   </td>
  </tr>
  <tr>
   <td>0x3F
   </td>
   <td>ROM Enable (Read) / Disable (Write)
   </td>
  </tr>
  <tr>
   <td>0x40-0x47
   </td>
   <td>Hard Disk Controller
   </td>
  </tr>
  <tr>
   <td>0x48
   </td>
   <td>HDC FIFO - 74LS245 K15 on disk board.
   </td>
  </tr>
  <tr>
   <td>0x60-0x62
   </td>
   <td>Cartridge Tape
   </td>
  </tr>
  <tr>
   <td>0x64-0x66
   </td>
   <td>Reel Tape
   </td>
  </tr>
  <tr>
   <td>0x70-0x7F
   </td>
   <td>MM58174 Real Time Clock
   </td>
  </tr>
</table>



<table>
  <tr>
   <td colspan="8" ><strong><em>0x2A - Floppy Disk Controller PARAM</em></strong>
   </td>
  </tr>
  <tr>
   <td>7
   </td>
   <td>6
   </td>
   <td>5
   </td>
   <td>4
   </td>
   <td>3
   </td>
   <td>2
   </td>
   <td>1
   </td>
   <td>0
   </td>
  </tr>
  <tr>
   <td>
   </td>
   <td>FDC Motor Enable?
   </td>
   <td>
   </td>
   <td>ROM enable?
   </td>
   <td>Double Density
   </td>
   <td>
   </td>
   <td colspan="2" >Floppy Drive Select
   </td>
  </tr>
</table>



### DIP Switch


<table>
  <tr>
   <td colspan="6" ><strong><em>0x38 - DIP Switch at Location E</em></strong>
   </td>
  </tr>
  <tr>
   <td><strong>Switch</strong>
<p>
<strong>Position</strong>
   </td>
   <td><strong>Port 38H Bit</strong>
   </td>
   <td><strong>As Received</strong>
   </td>
   <td><strong>OFF Function</strong>
   </td>
   <td><strong>ON Function</strong>
   </td>
   <td><strong>Notes</strong>
   </td>
  </tr>
  <tr>
   <td>1
   </td>
   <td>0
   </td>
   <td>OFF
   </td>
   <td>Auto Boot
   </td>
   <td>Enter ROM monitor
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>2
   </td>
   <td>1
   </td>
   <td>ON
   </td>
   <td>Floppy Boot
   </td>
   <td>Hard Disk Boot
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>3
   </td>
   <td>2
   </td>
   <td>OFF
   </td>
   <td>Normal operation
   </td>
   <td>RAM test
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>4
   </td>
   <td>3
   </td>
   <td>OFF
   </td>
   <td>
   </td>
   <td>
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>5
   </td>
   <td>4
   </td>
   <td>OFF
   </td>
   <td>
   </td>
   <td>
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>6
   </td>
   <td>5
   </td>
   <td>OFF
   </td>
   <td>Hard Disk (Unit 0)
   </td>
   <td>Cartridge Disk (Unit 3)
   </td>
   <td>Hard Disk Boot Selection
   </td>
  </tr>
  <tr>
   <td>7
   </td>
   <td>6
   </td>
   <td>OFF
   </td>
   <td>8” Floppy (77 tracks)
<p>
Use Interrupts for FDC
   </td>
   <td>5.25” Floppy (80 tracks)
<p>
Use Polling for FDC
   </td>
   <td>OFF Enables SD and GO commands.
   </td>
  </tr>
  <tr>
   <td>8
   </td>
   <td>7
   </td>
   <td>OFF
   </td>
   <td>Disable RAM Parity Check
   </td>
   <td>Enable RAM Parity Check
   </td>
   <td>Note: Unpopulated 74S280 Parity Generator/Checker at location 31D needs to be populated.
   </td>
  </tr>
</table>



<table>
  <tr>
   <td colspan="8" ><strong><em>0x3E - Floppy Disk FIFO Control</em></strong>
   </td>
  </tr>
  <tr>
   <td>7
   </td>
   <td>6
   </td>
   <td>5
   </td>
   <td>4
   </td>
   <td>3
   </td>
   <td>2
   </td>
   <td>1
   </td>
   <td>0
   </td>
  </tr>
  <tr>
   <td>
   </td>
   <td>
   </td>
   <td>FDCRD/WR#
   </td>
   <td>FIFO Reset
   </td>
   <td>
   </td>
   <td>
   </td>
   <td>
   </td>
   <td>
   </td>
  </tr>
</table>


The floppy interface seems to include a FIFO which is filled by the FDC’s DRQ signal.


## Replacing the ST-506 Controller with an SSD

The [z80_ssd project](https://github.com/hharte/z80_ssd) replaces the on-board ST-506 controller with a MicroSD card supporting an 80MB Drive 0, and a 10MB removable cartridge drive 3.


## Running in the SIMH Simulator

Compile SIMH using the patches in the digitex branch here:

[https://github.com/hharte/simh/tree/digitex](https://github.com/hharte/simh/tree/digitex)

Run the AltairZ80 simulator using the ibc_multistar configuration file from this repository:


```
./altairz80 ibc_multistar
```


Press ESC to get to the monitor prompt.  There will be a lot of debug messages scrolling because there is a lot of verbose debugging enabled.

