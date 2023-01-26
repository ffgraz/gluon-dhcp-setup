iptables -A INPUT -p udp --sport 67 --dport 68 -j ACCEPT
service dnsmasq stop 2>/dev/null || true
service dnsmasq disable 2>/dev/null || true

setup_dhcp() { # we're wrapping this in a function so it won't run until it's arrived in one piece
  # find 192.168.1.1
  INTF=$(ifconfig | grep -B1 "inet addr:192.168.1.1" | awk '$1!="inet" && $1!="--" {print $1}')
  udhcpc -i "$INTF"
}
(setup_dhcp </dev/null &>/dev/null) &
