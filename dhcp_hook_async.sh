#!/bin/bash

set -euo pipefail

IP=$2
MAC=$3

faketty () {
  script -qefc "$(printf "%q " "$@")" /dev/null
}

E() {
  echo $(tput bold)\# $MAC $IP $@$(tput sgr0)
}

ssh_host() {
  PASS="$1"
  USER="$2"
  shift 2

  PRECMD=()

  if [ -v FAKETTY ]; then
    PRECMD+=(faketty)
  fi

  PRECMD+=(sshpass -p "$PASS")

  "${PRECMD[@]}" ssh -o "ControlPath=none" -o "ControlMaster=no" -o "UserKnownHostsFile=/dev/null" -o StrictHostKeyChecking=no "$USER@$IP" "$@"
}

ssh_openwrt() {
  ex=255
  count=0
  if [ $ex -eq 255 ]; then
    set +e
    ssh_host "" root "$@" ; ex=$?
    set -e

    count=$(( $count + 1 ))
    if [ $count -gt 5 ]; then
      return $ex
    fi
  fi

  return $ex
}

ssh_host_openwrt() {
  ssh_openwrt "$@" &>/dev/null
}

ssh_host_openwrt_out() {
  ssh_openwrt "$@" 2> >(grep -v "Warning: Permanently added" >&2)
}

post() {
  cat "post/$1.sh" | ssh_host_openwrt_out "sh -"
}

scp_file() {
  sshpass -p "$1" scp -o "ControlPath=none" -o "ControlMaster=no" -o "UserKnownHostsFile=/dev/null" -o StrictHostKeyChecking=no $3 "$4" "$2"@$IP:/"$5" &>/dev/null

  if [ $? -ne 0 ]; then
    E "failed to upload file" $3

    exit 1
  fi
}

scp_file_openwrt() {
  scp_file "" root "-O" "$1" "$2"
}

E AP connected

timeout 40 /bin/sh -c -- "while ! timeout 0.5 ping -c 1 -n $IP &>/dev/null; do :; done"
if [ $? -ne 0 ]; then
  E "timeout, aborting"

  exit 1
fi

sleep 1

if cat /dev/null | ssh_host_openwrt; then
  TYPEACTION=($(post get-type))
  TYPE="${TYPEACTION[0]}"
  ACTION="${TYPEACTION[1]}"

  case "$ACTION" in
    flash)
      E "$TYPE" AP: preparing gluon flash

      BOARD_NAME=$(ssh_host_openwrt_out cat /tmp/sysinfo/board_name)

      E GLUON: resolving image for "$BOARD_NAME" channel "$CHANNEL"

      URL=$(bash try_board_to_image.sh "$BOARD_NAME")

      if [ -z "$URL" ]; then
        E GLUON: failed to resolve
        exit 2
      fi

      E GLUON: fetching image "$URL"

      BASE=$(basename "$URL")

      pushd "$(mktemp -d)" >/dev/null
      wget -q "$URL" "-O$BASE"

      E "$TYPE" AP: scp image "$BASE"

      scp_file_openwrt "$BASE" "/tmp/$BASE"

      E "$TYPE" AP: wait

      popd >/dev/null

      set +e
      post wait
      set -e

      E "$TYPE" AP: executing sysupgrade

      echo "sysupgrade -n -v /tmp/$BASE" | ssh_host_openwrt_out -t sh -l - || true

      E "$TYPE" AP: rebooting into config mode

      exit 0
      ;;
    setup)
      E "$TYPE" AP wait

      set +e
      post wait
      set -e

      E "$TYPE" AP "Configure gluon"

      if [ -e post/custom.sh ]; then
        E "$TYPE" AP "Using custom script"

        post custom
      else
        post set-name
      fi

      if ! [ -v GLUON_NO_SKIP ]; then
        post configure-gluon-skip
      fi

      (post blink-and-die &)
      sleep 5s

      E "$TYPE" AP DONE "Configured $MAC"
      exit 0
      ;;
    ?)
      E MAIN "General failure."
      exit 2
      ;;
  esac
fi
