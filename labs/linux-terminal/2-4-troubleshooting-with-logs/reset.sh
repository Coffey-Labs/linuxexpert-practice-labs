systemctl stop broken.service 2>/dev/null
rm -f /etc/systemd/system/broken.service
rm -rf /etc/systemd/system/broken.service.d
systemctl daemon-reload
systemctl reset-failed broken.service 2>/dev/null
[ -n "$(state_get had-known-host)" ] || ssh-keygen -q -R 10.99.0.1 -f /root/.ssh/known_hosts >/dev/null 2>&1
rm -f /root/.ssh/known_hosts.old
true
