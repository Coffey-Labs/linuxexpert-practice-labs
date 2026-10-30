pkg_install nginx lsof
systemctl enable --quiet --now nginx
user_add alice -s /bin/bash

# Task 3: a service to cap.
cat >/usr/local/bin/heartbeat <<'X'
#!/bin/bash
while :; do
	date
	sleep 5
done
X
chmod 755 /usr/local/bin/heartbeat
cat >/etc/systemd/system/heartbeat.service <<'X'
[Unit]
Description=Heartbeat

[Service]
ExecStart=/usr/local/bin/heartbeat

[Install]
WantedBy=multi-user.target
X

# Task 5: a non-root service on a privileged port; fails as it is.
id webapp >/dev/null 2>&1 || useradd -r -s /sbin/nologin -M webapp
mkdir -p /srv/webapp
echo "webapp works" >/srv/webapp/index.html
cat >/etc/systemd/system/webapp.service <<'X'
[Unit]
Description=Lab web application
After=network.target

[Service]
User=webapp
ExecStart=/usr/bin/python3 -m http.server 81 --directory /srv/webapp

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --quiet --now heartbeat.service
systemctl enable --quiet webapp.service
systemctl start webapp.service 2>/dev/null || true
