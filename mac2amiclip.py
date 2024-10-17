#!/usr/bin/env python3

# Clipboard sync tool Mac/Linux to Amiga
# Marcus Jüttner
# v0.1 08.10.2024

import os
import sys
import base64
import socket
import pyperclip

# Konfiguration
LANG = 'de_DE.UTF-8'
HOST_AMIGA = '192.168.20.193'
PORT_AMIGA = 1111
MAX_BYTES = 100000
LOGFILE = 'mac2amiclip.log'

# Funktion, um den Clipboard-Inhalt zu erhalten
def get_clipboard():
    try:
        return pyperclip.paste()
    except Exception as e:
        log_message(f"Error getting clipboard content: {e}")
        return None

# Funktion, um Nachrichten ins Logfile zu schreiben
def log_message(message):
    logfile_path = os.path.join(os.path.dirname(__file__), LOGFILE)
    with open(logfile_path, 'a') as logfile:
        logfile.write(message + '\n')

# Hauptlogik
def main():
    clipboard_content = get_clipboard()

    if not clipboard_content:
        log_message("Clipboard is empty")
        sys.exit(0)
    else:
        log_message(clipboard_content)

    clipboard_content = clipboard_content[:MAX_BYTES]
    clipboard_content = clipboard_content.replace('https://', 'http://')

    try:
        clipboard_content = clipboard_content.encode('utf-8').decode('iso-8859-1')
    except UnicodeEncodeError as e:
        log_message(f"Error encoding clipboard content: {e}")
        sys.exit(1)

    encoded_content = base64.b64encode(clipboard_content.encode('iso-8859-1')).decode('utf-8')

    try:
        with socket.create_connection((HOST_AMIGA, PORT_AMIGA), timeout=2) as sock:
            sock.sendall(encoded_content.encode('utf-8'))
        log_message("nc ok")
    except (socket.error, socket.timeout) as e:
        log_message(f"nc error: {e}")

    sys.exit(0)

if __name__ == '__main__':
    main()
