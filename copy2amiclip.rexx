/* Paste2AmiClip.rexx */

/* About:
Copy text on your modern MacOS, Linux or Windows
and send it over your network to your good old AmigaOS
Author: Marcus Juettner

This is the Amiga part in ARexx
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
18. Oct. 2024: Version 0.1 (initial Version)
*/


/* Variables */
myport = 1111
logfile = 't:copy2amiclip.log'


/* Check libs */
l="rexxtricks.library";if ~show("L",l) then;if ~addlib(l,0,-30) then do;say "can't find" l;exit;end
l="rexxsupport.library";if ~show("L",l) then;if ~addlib(l,0,-30) then do;say "can't find" l;exit;end
l="rmh.library";if ~show("L",l) then;if ~addlib(l,0,-30) then do;say "can't find" l;exit;end
l="rxsocket.library";if ~show("L",l) then;if ~addlib(l,0,-30) then do;say "can't find" l;exit;end

/* Delete old logs */
if exists(logfile) then delete(logfile)

/* Main */
prg = ProgramName()
portname = 'COPY2AMICLIP'
maxtransfer = 5465
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

call writelog 'listening ...'

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
            call writelog 'received base64 data: ' || buf
            /* quit process if a "quit" comes over the line */
            if buf = 'quit' then do
                say "quitting process"
                call writelog 'quitting'
                call CloseSocket(lsock)
                exit(0)
            end
            else do
                decodedString = decodeBase64(buf)
                call writelog 'decoded data: ' || decodedString

                /* copy decoded string to clipboard */
                if ~WRITECLIPBOARD(0,decodedString) then
                  call err "copy to clip error:" errno()
                else
                  call writelog 'copied to clip'

                /* short brake for the system to rest :-) */
                delay(50)
            end
        end
        if ( len < 0 ) & ( errno() ~= 35 )
            then call err "recv() error:" errno()

        call CloseSocket(lsock)
        call writelog 'End'

    end
end

exit (0)

/* Subroutines */
/* Errorhandling */
err: procedure expose prg logfile
parse arg msg 
    say prg":" msg
    call writelog msg
    exit

/* Base64-Char to its index */
decodeBase64Char:
  parse arg char
  index = pos(char, base64chars) - 1
  return index

/* Decode Base64 */
decodeBase64:
  parse arg base64string
  decodedString = ''
  binaryString = ''

  /* Remove padding (=) */
  base64string = strip(base64string, 'T', padding)

  /* Verarbeite den Base64-String in 4-Zeichen-Gruppen */
  do i = 1 to length(base64string) by 4
    part = substr(base64string, i, 4)

    /* Jedes Zeichen in eine 6-Bit-Binärzahl umwandeln */
    do j = 1 to length(part)
      char = substr(part, j, 1)
      index = decodeBase64Char(char)
      binaryPart = D2B(index, 6) /* Konvertiere in 6-Bit-Binärformat */
      binaryString = binaryString || binaryPart
    end

    /* Zerlege den kombinierten Binärstring in 8-Bit-Blöcke (Bytes) */
    do while length(binaryString) >= 8
      byte = substr(binaryString, 1, 8)
      binaryString = substr(binaryString, 9)
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
  do i = 1 to length(binary)
    if substr(binary, i, 1) = '1' then decimal = decimal + 2 ** (length(binary) - i)
  end
  return decimal

/* Write logfile */
writelog: procedure expose logfile
  parse arg logstring

  if ~exists(logfile) then do
    open('file', logfile, 'w')
    if RC = 0 then
      say 'error creating logfile'
    writeln('file', 'Start:')
    if RC = 0 then
      say 'error writing logfile'
    close('file')
  end

  if open('file', logfile, 'a') then do
    logstring = date() || ' ' || time() || ': ' || logstring
    writeln('file', logstring)
    close('file')
  end
  else do
    say 'error appending logfile'
    exit (1)
  end

  return 0