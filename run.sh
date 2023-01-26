#!/bin/bash

export IFNAME="$1"
if [ -z "$2" ]; then
  export CHANNEL=experimental
else
  export CHANNEL="$2"
fi
export USER=$SUDO_USER

nmcli d d "$IFNAME"
ip l s down dev "$IFNAME"

ip addr flush dev $IFNAME
ip addr add 192.168.1.10/24 dev $IFNAME
ip link set dev $IFNAME up

./wait_main.sh &
./dhcpd.sh &

trap terminate SIGINT SIGTERM
terminate(){
    pkill -SIGKILL -P $$
    exit
}

wait
