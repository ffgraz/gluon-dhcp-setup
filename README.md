# ffgraz-dhcp-setup

(Re-)Flashes gluon and openwrt devices

# Usage

```sh
sudo bash run.sh INTERFACE [<CHANNEL>]
```

# Note

For this script to work properly, it needs to be in your gluon/ folder (it is irrelevant if the firmware was built, the only thing we need is the lua scripts to get the board name -> url translation)

Depends:
- dhcpd
- lua 5.1
- openssh
- curl
