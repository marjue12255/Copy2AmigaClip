/* Paste2AmiClip.rexx */

/* About:
Copy text on your modern MacOS, Linux or Windows
and send it over your network to your good old AmigaOS
Author: Marcus Juettner
*/

/* Dependencies:
Amiga:
AmigaOS:        Developed and tested with AmigaOS 3.2
RexxTricks Lib: http://aminet.net/package/util/rexx/RexxTricks_386.lha
RXSocket Lib:   http://aminet.net/package/comm/tcp/rxsocket
Mac:
MacOS:          Developed with MacOS 15
*/

/* History:
16. Oct. 2024: Version 0.1 (initial Version)
*/


/* Variables */
myport = 1111

/* Check libs */
l="rexxtricks.library";if ~show("L",l) then;if ~addlib(l,0,-30) then do;say "can't find" l;exit;end
l="rexxsupport.library";if ~show("L",l) then;if ~addlib(l,0,-30) then do;say "can't find" l;exit;end
l="rmh.library";if ~show("L",l) then;if ~addlib(l,0,-30) then do;say "can't find" l;exit;end
l="rxsocket.library";if ~show("L",l) then;if ~addlib(l,0,-30) then do;say "can't find" l;exit;end

/* Main */
prg = ProgramName()
portname = 'MAC2AMICLIP'
maxtransfer = 256
padding = '='
base64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'


if ~Open("STDERR","*","W") then do
  call err "can't open STDERR:" errno()
end

if ~OpenPort(portname) then do
  call err "can't open port:" errno()
end

sock = socket("INET","STREAM","IP")
if sock<0 then call err "can't create socket:" errno()

local.ADDRFAMILY = "INET"
local.ADDRADDR  = 0
local.ADDRPORT  = myport
if bind(sock,"LOCAL")<0 then call err "can't bind to port:" errno()

sig = PortSignal(portname)
SEL.READ.0=sock
open = 1
do while open

    if Listen(sock,5)<0 then call err "listen error:" errno()

    res = WaitSelect("SEL",,,sig)

    pkt = GetPkt(portname)
    if pkt ~= null() then do
        comm= GetArg(pkt)
        call reply(pkt)
        if upper(comm) == "QUIT" then open = 0
    end

    if sel.0.read then do

        lsock = accept(sock,"REMOTE")
        if lsock<0 then call err "accept() error:" errno()

        len = recv(lsock,"BUF",maxtransfer)
        if len>0 then do
            if buf = 'quit' then
                exit(0)
            else do
                decodedString = decodeBase64(buf)

                /* copy decoded string to clipboard */
                if ~WRITECLIPBOARD(0,decodedString) then
                  call err "copy to clip error:" errno()

                /* short brake for the system to rest :-) */
                delay(50)
            end
        end
        if ( len < 0 ) & ( errno() ~= 35 )
            then call err "recv() error:" errno()

        call CloseSocket(lsock)

    end
end

exit (0)


/* Subroutines */
/* Errorhandling */
err: procedure expose prg
parse arg msg
    say prg":" msg
    exit

/* Base64-Char to its index */
decodeBase64Char:
  parse arg char
  index = POS(char, base64chars) - 1
  return index

/* Decode Base64 */
decodeBase64:
  parse arg base64string
  decodedString = ''
  binaryString = ''

  /* Remove padding (=) */
  base64string = STRIP(base64string, 'T', padding)

  /* Verarbeite den Base64-String in 4-Zeichen-Gruppen */
  do i = 1 to LENGTH(base64string) by 4
    part = SUBSTR(base64string, i, 4)

    /* Jedes Zeichen in eine 6-Bit-Binärzahl umwandeln */
    do j = 1 to LENGTH(part)
      char = SUBSTR(part, j, 1)
      index = decodeBase64Char(char)
      binaryPart = D2B(index, 6) /* Konvertiere in 6-Bit-Binärformat */
      binaryString = binaryString || binaryPart
    end

    /* Zerlege den kombinierten Binärstring in 8-Bit-Blöcke (Bytes) */
    do while LENGTH(binaryString) >= 8
      byte = SUBSTR(binaryString, 1, 8)
      binaryString = SUBSTR(binaryString, 9)
      decodedChar = B2D(byte)  /* Konvertiere Binär -> Dezimal */
      decodedString = decodedString || D2C(decodedChar)
    end
  end

  return decodedString

/* Decimal to binary */
D2B: procedure
  parse arg num, bits
  binary = ''
  do i = bits to 1 by -1
    if num >= 2 ** (i - 1) then do
      binary = binary || '1'
      num = num - 2 ** (i - 1)
    end
    else binary = binary || '0'
  end
  return binary

/* Binary to decimal */
B2D: procedure
  parse arg binary
  decimal = 0
  do i = 1 to LENGTH(binary)
    if SUBSTR(binary, i, 1) = '1' then decimal = decimal + 2 ** (LENGTH(binary) - i)
  end
  return decimal
