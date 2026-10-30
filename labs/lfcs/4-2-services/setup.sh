# Task 4: a working program behind a broken unit.
id ticker >/dev/null 2>&1 || useradd -r -s /sbin/nologin -M ticker
cat >/usr/local/bin/ticker <<'X'
#!/bin/bash
# Writes a tick every 10 seconds.
while :; do
	echo "tick $(date +%T)"
	sleep 10
done
X
chmod 755 /usr/local/bin/ticker
cat >/etc/systemd/system/ticker.service <<'X'
[Unit]
Description=Lab ticker

[Service]
User=tickerd
ExecStart=/usr/local/bin/tick

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --quiet ticker.service
systemctl start ticker.service 2>/dev/null || true
