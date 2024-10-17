#!/bin/zsh

# Clipboard sync tool Mac/Linux to Amiga
# Marcus Jüttner
# v0.1 08.10.2024

export LANG=de_DE.UTF-8

HOST_AMIGA=192.168.20.193
PORT_AMIGA=1111
MAX_BYTES=100000
LOGFILE=mac2amiclip.log
CLIPBOARD=$(pbpaste -Prefer txt)


if [ -z "$CLIPBOARD" ]; then
  echo "Clipboard is empty" > $(dirname $0)/$LOGFILE
  exit 0
else
  echo "$CLIPBOARD" > $(dirname $0)/$LOGFILE
fi

echo -n "" >> $(dirname $0)/$LOGFILE

echo -n "$CLIPBOARD" \
 | cut -b 1-${MAX_BYTES} \
 | sed 's/^https:\/\//http:\/\//' \
 | iconv -f UTF-8 -t ISO-8859-1 \
 | base64 \
 | nc -G 2 $HOST_AMIGA $PORT_AMIGA

if [ $? -ne 0 ]; then
  echo "nc error" >> $(dirname $0)/$LOGFILE
else
  echo "nc ok" >> $(dirname $0)/$LOGFILE
fi

exit 0
