if [ -e /etc/config/gluon-setup-mode ] && touch /automatic_setup &>/dev/null; then
  # gluon
  if [ "$(uci get gluon-setup-mode.@setup_mode[0].configured)" != "1" ]; then
    # unconfigured gluon
    echo "GLUON setup"
  else
    # configured gluon or recovery, reflash
    echo "GLUON flash"
  fi
else
  # openwrt
  echo "OPENWRT flash"
fi
