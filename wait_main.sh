#!/bin/bash

IP=192.168.1.1

E() {
  echo $(tput bold)\# $MAC $IP $@$(tput sgr0)
}

ssh_cmd() {
  ssh -o "UserKnownHostsFile=/dev/null" -o StrictHostKeyChecking=no root@192.168.1.1 "$@"
}

post() {
  cat "post/$1.sh" | ssh_cmd sh -
}

while sleep 5s; do
  MAC="00:00:00:00:00:00"

  if ping -w1 -c1 192.168.1.1 >/dev/null 2>/dev/null; then
    E MAIN "Probing 192.168.1.1"

    if timeout 3 ssh -o "UserKnownHostsFile=/dev/null" -o StrictHostKeyChecking=no root@192.168.1.1 &>/dev/null; then
      MAC=$(post get-mac-vanilla)

      ACTION=$(post get-type)

      case "$ACTION" in
        flash)
          E MAIN "Flash gluon"
          bash dhcp_hook_async.sh commit 192.168.1.1 "$MAC"
          ;;
        gluon)
          E MAIN "Wait"
          post wait

          E MAIN "Configure gluon"
          post set-name
          if [ -z "$GLUON_NO_SKIP" ]; then
            post configure-gluon-skip
          fi
          (post blink-and-die &)
          sleep 5s

          E MAIN DONE "Configured $MAC"
          ;;
        ?)
          E MAIN "General failure."
          ;;
      esac

      E MAIN "Next probe"
    else
      E MAIN "Probing failed"
    fi
  fi
done
