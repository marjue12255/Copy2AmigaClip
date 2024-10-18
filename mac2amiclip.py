#!/usr/bin/env python3

# /* About:
# Copy text on your modern MacOS, Linux or Windows
# and send it over your network to your good old AmigaOS
# Author: Marcus Juettner

# This is the Mac part in Python
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
# */

import os
import sys
import base64
import socket
import pyperclip

# Configuration
HOST_AMIGA = '192.168.20.193'
PORT_AMIGA = 1111
MAX_BYTES = 4096
LOGFILE = '/tmp/mac2amiclip.log'
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
    logfile_path = os.path.join(os.path.dirname(__file__), LOGFILE)
    with open(logfile_path, 'a') as logfile:
        logfile.write(message + '\n')

# Main
def main():
    clipboard_content = get_clipboard()

    if not clipboard_content:
        log_message("clipboard is empty")
        sys.exit(0)
    else:
        log_message(clipboard_content)

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
