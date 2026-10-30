systemctl disable --now --quiet le-lab-watch.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-watch.service /usr/local/lib/le-lab/watch.sh
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
d=$(state_get default-before)
[ -n "$d" ] && [ "$(systemctl get-default)" != "$d" ] && systemctl set-default "$d" >/dev/null 2>&1
true
