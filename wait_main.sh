#!/bin/bash

set -euo pipefail

IP=192.168.1.1

E() {
  echo $(tput bold)\# $MAC $IP $@$(tput sgr0)
}

ssh_cmd() {
  ssh -o "ControlMaster=no" -o "UserKnownHostsFile=/dev/null" -o StrictHostKeyChecking=no root@192.168.1.1 "$@" 2> >(grep -v "Warning: Permanently added" >&2)
}

post() {
  cat "post/$1.sh" | ssh_cmd sh -
}

while sleep 5s; do
  MAC="00:00:00:00:00:00"

  if ping -w1 -c1 192.168.1.1 >/dev/null 2>/dev/null; then
    # E MAIN "Probing 192.168.1.1"
    true

    if timeout 3 ssh -o "UserKnownHostsFile=/dev/null" -o StrictHostKeyChecking=no root@192.168.1.1 &>/dev/null; then
      MAC=$(post get-mac-vanilla)

      E MAIN "Switch to DHCP"

      post do-dhcp

      sleep 5s

      # E MAIN "Next probe"
    else
      # E MAIN "Probing failed"
      true
    fi
  fi
done
