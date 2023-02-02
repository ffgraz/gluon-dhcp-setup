DEV=$(lua -e 'print(require("platform_info").get_board_name())' | sed 's|,|-|g')
MAC=$(cat /lib/gluon/core/sysconfig/primary_mac | cut -d":" -O"-" -f5,6)

pretty-hostname "$DEV-$MAC"

uci commit
