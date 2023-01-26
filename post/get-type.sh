if [ -e /etc/config/gluon-setup-mode ]; then
  # gluon
  if [ "$(uci get gluon-setup-mode.@setup_mode[0].configured)" != "1" ]; then
    # unconfigured gluon
    echo "GLUON setup"
  else
    # configured gluon, reflash
    echo "GLUON flash"
  fi
else
  # openwrt
  echo "OPENWRT flash"
fi
