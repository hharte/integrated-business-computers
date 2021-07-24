# IBC/Integrated Business Computers - MultiStar


# IBC MultiStar* SERIES   Loader PROM  V3.4

To get into the Loader PROM monitor, set DIP Switch E position 3 to OFF, and press ESC on any one of the 10 serial ports.  Signs on with:


<table>
  <tr>
   <td>Command
   </td>
   <td>Argument
   </td>
   <td>Description
   </td>
   <td>Address
   </td>
   <td>Notes
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
   <td>0x05d5
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
   <td>0x05df
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
   <td>
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
   <td>0x05ff
   </td>
   <td>Fills memory from 8000-9A00 with specified byte.
   </td>
  </tr>
  <tr>
   <td>FI
   </td>
   <td>none
   </td>
   <td>Fill Increment
   </td>
   <td>0x060f
   </td>
   <td>Fills memory from 8000-9A00 with an incrementing pattern 0-255.
   </td>
  </tr>
  <tr>
   <td>DD
   </td>
   <td>none
   </td>
   <td>
   </td>
   <td>0x091f
   </td>
   <td>Set 0xE539 to 16
   </td>
  </tr>
  <tr>
   <td>SD
   </td>
   <td>none
   </td>
   <td>
   </td>
   <td>0x0631
   </td>
   <td>Set 0xE539 to 13
<p>
Works when DIP switch set to 0x44, not 0x04.
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
   <td>0x0637
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
   <td>0x063b
   </td>
   <td>Returns FDC Status from 1795 and PARAM register from 0x2A.
   </td>
  </tr>
  <tr>
   <td>H1
   </td>
   <td>none
   </td>
   <td>Writes 1 to 0E420h
   </td>
   <td>0x0654
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>H0
   </td>
   <td>none
   </td>
   <td>Writes 0 to 0E420h
   </td>
   <td>0x0658
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>US
   </td>
   <td>&lt;0,1,2,3>
   </td>
   <td>Unit Select
   </td>
   <td>0x065d
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
   <td>
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
   <td>
   </td>
   <td>Track range: 0-78
   </td>
  </tr>
  <tr>
   <td>RR
   </td>
   <td>none
   </td>
   <td>Read (verify) different floppy tracks.
   </td>
   <td>
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>WR
   </td>
   <td>&lt;track>
   </td>
   <td>Write floppy sector
   </td>
   <td>
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
   <td>
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
   <td>0x15e
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
   <td>0x02f7
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
   <td>0x0768
   </td>
   <td>Allows the user to choose another UART by pressing ESC.
   </td>
  </tr>
  <tr>
   <td>SE
   </td>
   <td>none
   </td>
   <td>??
   </td>
   <td>0x077a
   </td>
   <td>
   </td>
  </tr>
  <tr>
   <td>GO
   </td>
   <td>&lt;addr>
   </td>
   <td>Start execution at address.
   </td>
   <td>
   </td>
   <td>Works when the DIP switch is set to 0x44, not 0x04.
   </td>
  </tr>
</table>



## Important memory locations:

0xE100 - Floppy and hard disk bootstraps are copied from ROM to here.  The second stage loader read from disk will use jump table entry points here to do disk reads.

0xE400 - FDC Param (string@ 0916h) (copy of register at 0x2A)

0xE401 - FDC Status (string@ 090Dh)

0xE415 - Floppy Drive Unit 0-3 (maybe hard drive too?)

0xE41C - Written by T0 command.

0xE420 - Written by the H0/1 command.

0xE539 - Set to 0x10 by the DD command.

0x8000-0x9A00 - Memory buffer used for Disk I/O (26 sectors of 128 bytes each.)  This is enough for one track worth of data.


# Running in the SIMH Simulator

Compile SIMH using the patches in the digitex branch here:

[https://github.com/hharte/simh/tree/digitex](https://github.com/hharte/simh/tree/digitex)

Run the AltairZ80 simulator using the ibc_multistar configuration file from this repository:


```
./altairz80 ibc_multistar
```


Press ESC to get to the monitor prompt.  There will be a lot of debug messages scrolling because there is a lot of verbose debugging enabled.

