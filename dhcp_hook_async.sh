#!/bin/bash

IP=$2
MAC=$3

E() {
  echo $(tput bold)\# $MAC $IP $@$(tput sgr0)
}

ssh_host() {
  sshpass -p "$1" ssh -o "UserKnownHostsFile=/dev/null" -o StrictHostKeyChecking=no $2@$IP "$3"
}


ssh_host_openwrt() {
  ssh_host "" root "$1" &>/dev/null
}

ssh_host_openwrt_out() {
  ssh_host "" root "$1"
}

scp_file() {
  sshpass -p "$1" scp -o "UserKnownHostsFile=/dev/null" -o StrictHostKeyChecking=no $3 "$4" "$2"@$IP:/"$5" &>/dev/null

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

ssh_host_openwrt
if [ $? -eq 0 ]; then
  E OPENWRT AP: preparing gluon flash

  BOARD_NAME=$(ssh_host_openwrt_out "cat /tmp/sysinfo/board_name")

  E GLUON: resolving image for "$BOARD_NAME"

  URL=$(bash try_board_to_image.sh "$BOARD_NAME")

  if [ -z "$URL" ]; then
    E GLUON: failed to resolve
    exit 2
  fi

  E GLUON: fetching image "$URL"

  BASE=$(basename "$URL")

  pushd "$(mktemp -d)" >/dev/null
  wget -q "$URL" "-O$BASE"

  E OPENWRT AP: scp image "$BASE"

  scp_file_openwrt "$BASE" "/tmp/$BASE"

  E OPENWRT AP: wait

  popd >/dev/null

  cat post/wait.sh | ssh_host_openwrt sh -

  E OPENWRT AP: executing sysupgrade

  ssh_host_openwrt "sysupgrade -n -v /tmp/$BASE"

  E OPENWRT AP: rebooting into config mode

  exit 0
fi
