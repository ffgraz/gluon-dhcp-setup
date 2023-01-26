service dnsmasq stop

for intf in eth0 eth1 wlan0 wlan1; do
  f="/sys/class/net/$intf/device/net/$intf/address"
  if [ -e $f ]; then
    cat "$f"
    exit
  fi
done
