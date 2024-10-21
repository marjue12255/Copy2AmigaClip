#!/bin/zsh

# /* About:
# Copy text on your modern MacOS, Linux or Windows
# and send it over your network to your good old AmigaOS
# Author: Marcus Juettner

# This is the Mac part in shell
# */

# /* History:
# 18. Oct. 2024: Version 0.1 (initial Version)
# */

# variables
LANG=de_DE.UTF-8
HOST_AMIGA=192.168.20.193
PORT_AMIGA=1111
MAX_BYTES=4096
LOGFILE=/tmp/mac2amiclip.log
AMIGA_CP='ISO-8859-1'

export LANG
CLIPBOARD=$(pbpaste -Prefer txt)

# main
if [ -z "$CLIPBOARD" ]; then
  echo "Clipboard is empty" > "$LOGFILE"
  exit 0
else
  echo "clip: $CLIPBOARD" > "$LOGFILE"
fi

echo -n "" >> $LOGFILE

echo -n "$CLIPBOARD" \
 | cut -b 1-${MAX_BYTES} \
 | sed 's/^https:\/\//http:\/\//' \
 | iconv -t ${AMIGA_CP} \
 | base64 \
 | nc -G 2 $HOST_AMIGA $PORT_AMIGA

if [ $? -ne 0 ]; then
  echo "nc error" >> "$LOGFILE"
else
  echo "nc ok" >> "$LOGFILE"
fi

exit 0
