#!/usr/bin/env python3

# /* About:
# Copy text on your modern MacOS, Linux or Windows
# and send it over your network to your good old AmigaOS
# Author: Marcus Juettner

# This is the Mac, Linux or Windows part in Python
# */

# /* Dependencies:
# Amiga:
# AmigaOS:        Developed and tested with AmigaOS 3.2
# RexxTricks Lib: http://aminet.net/package/util/rexx/RexxTricks_386.lha
# RXSocket Lib:   http://aminet.net/package/comm/tcp/rxsocket
# Mac:
# MacOS:          Developed with MacOS 15
# */

# /* History:
# 18. Oct. 2024: Version 0.1 (initial Version)
# 21. Oct. 2024: Support for Wayland on Linux
# */

import os
import sys
import base64
import socket
import pyperclip
from datetime import datetime

# Configuration
HOST_AMIGA = '192.168.20.193'
PORT_AMIGA = 1111
MAX_BYTES = 4096
LOGFILE = '/tmp/copy2amiclip.log'
AMIGA_CP = 'iso-8859-1'
LOCAL_CP = 'utf-8'

# Get Clipboard content
def get_clipboard():
    try:
        return pyperclip.paste()
    except Exception as e:
        log_message(f"Error getting clipboard content: {e}")
        return None

# Write logfile
def log_message(message):
    now = datetime.now()
    mydate = now.strftime("%d.%m.%Y %H:%M:%S")
    with open(LOGFILE, 'a') as logfile:
        logfile.write(mydate + ': ' + message + '\n')

# Main
def main():
    # MacOS uses pbbaste which is detected automaticly
    # Windows uses whatever which is detected automaticly
    # Linux depends. If XOrg is used pyperclip uses xsel or xclip automaticly
    # If Wayland is used a hint is neccesary.
    if sys.platform == 'linux':
        if 'XDG_SESSION_TYPE' in os.environ:
            if os.environ['XDG_SESSION_TYPE'] == 'wayland':
                log_message('Linux Wayland detected')
                pyperclip.set_clipboard("wl-clipboard")
            elif os.environ['XDG_SESSION_TYPE'] == 'x11':
                log_message('Linux XOrg dedected')
    elif sys.platform == 'darwin':
        log_message('MacOS deteted')
    elif sys.platform == 'win32':
        log_message('Windows dedected')
    else:
        log_message('Platform ' + sys.platform + ' not supported (yet)')

    clipboard_content = get_clipboard()

    if not clipboard_content:
        log_message("clipboard is empty")
        sys.exit(0)
    else:
        log_message('clip content: ' + clipboard_content)

    clipboard_content = clipboard_content[:MAX_BYTES]

    try:
        clipboard_content = clipboard_content.encode(LOCAL_CP).decode(AMIGA_CP)
    except UnicodeEncodeError as e:
        log_message(f"error encoding clipboard content: {e}")
        sys.exit(1)

    encoded_content = base64.b64encode(clipboard_content.encode(AMIGA_CP)).decode(LOCAL_CP)

    try:
        with socket.create_connection((HOST_AMIGA, PORT_AMIGA), timeout=2) as sock:
            sock.sendall(encoded_content.encode(LOCAL_CP))
        log_message("send to Amiga ok")
    except (socket.error, socket.timeout) as e:
        log_message(f"send to Amiga error: {e}")

    sys.exit(0)

if __name__ == '__main__':
    main()
