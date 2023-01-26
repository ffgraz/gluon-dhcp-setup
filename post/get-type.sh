if [ -e /etc/config/gluon-setup-mode ]; then
  # gluon
  if [ "$(uci get gluon-setup-mode.@setup_mode[0].configured)" != "1" ]; then
    # unconfigured gluon
    echo "gluon"
  else
    # configured gluon, reflash
    echo "flash"
  fi
else
  # openwrt
  echo "flash"
fi
