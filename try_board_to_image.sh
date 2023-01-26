#!/bin/bash

channel="$CHANNEL"
if [ -z "$channel" ]; then
  channel="experimental"
fi

EQUALS=""

declare -A gluon2img

PREFIX="http://ffgraz.mkg20001.io/$channel/images/sysupgrade/"

LINKS=$(curl -s "https://ffgraz.mkg20001.io/$channel/images/sysupgrade/" | grep -o 'href=".*"' | grep -o 'gluon.*[^"]')
for LINK in $LINKS; do
  BOARD=$(echo "$LINK" | sed -r -e "s|-sysupgrade\\.bin\\.gz\$||g" -e "s|-sysupgrade\\.bin\$||g" -e "s|gluon-[a-z0-9]*-[a-z0-9.%A-Z]*-||g")
  FUZZBOARD=$(echo "$BOARD" | sed -r -e "s|[^0-9a-z]||g")
  # echo "$FUZZBOARD - $LINK"
  gluon2img[$BOARD]="$LINK"
  gluon2img[$FUZZBOARD]="$LINK"
  EQUALS="$EQUALS
$FUZZBOARD=$PREFIX$LINK"
done

for IMG in $(lua get_list.lua); do
  OLDIFS="$IFS"
  IFS="="
  DEV=( $IMG )
  LINK="${gluon2img[${DEV[1]}]}"
  if [ -z "$LINK" ]; then
    LINK="${gluon2img[${DEV[0]}]}"
  fi
  if [ ! -z "$LINK" ]; then
    EQUALS="$EQUALS
${DEV[0]}=$PREFIX$LINK"
  else
    # echo "FAILED TO MAP $IMG - ${DEV[0]} - ${DEV[1]}" >&2
    true
  fi
done

DEV="$1"
DEVFUZZ=$(echo "$DEV" | sed -r -e "s|[^0-9a-z]||g")

# echo "--- $DEVFUZZ"

OUT=$(echo "$EQUALS" | grep "$DEVFUZZ")
URLS=$(echo "$OUT" | sed "s|^.*=||g" | uniq)

if [ -z "$URLS" ]; then
  echo "Failed to map $DEVFUZZ" >&2
  exit 2
fi

# echo "Mapped $DEVFUZZ to $URLS" >&2

echo "$URLS"
