(logread && logread -f) | while read line; do
  if echo "$line" | grep "init complete"; then
    kill $$
  fi
done
