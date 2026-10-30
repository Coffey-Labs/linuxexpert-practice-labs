pkg_install sysstat
# Task 1: collection off.
if is_rhel; then
	systemctl disable --quiet --now sysstat.service sysstat-collect.timer sysstat-summary.timer 2>/dev/null || true
else
	sed -i 's/^ENABLED=.*/ENABLED="false"/' /etc/default/sysstat
	systemctl disable --quiet --now sysstat.service sysstat-collect.timer sysstat-summary.timer 2>/dev/null || true
fi
mkdir -p /usr/local/lib/le-lab
# Task 2: a service that keeps one CPU busy.
cat >/usr/local/lib/le-lab/report-builder <<'Y'
#!/bin/bash
while :; do :; done
Y
# Task 3: a process that sleeps very briefly, over and over.
cat >/usr/local/lib/le-lab/msgbroker.py <<'Y'
import time
open("/proc/self/comm", "w").write("msgbroker")
while True:
    time.sleep(0.0002)
Y
chmod 755 /usr/local/lib/le-lab/report-builder
cat >/etc/systemd/system/report-builder.service <<'Y'
[Unit]
Description=Nightly report builder

[Service]
ExecStart=/usr/local/lib/le-lab/report-builder

[Install]
WantedBy=multi-user.target
Y
cat >/etc/systemd/system/message-broker.service <<'Y'
[Unit]
Description=Message broker

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/msgbroker.py

[Install]
WantedBy=multi-user.target
Y
# Task 4: a slow unit at boot.
cat >/etc/systemd/system/cache-prime.service <<'Y'
[Unit]
Description=Prime the application cache

[Service]
Type=oneshot
ExecStart=/bin/sleep 25
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
Y
systemctl daemon-reload
systemctl enable --quiet cache-prime.service
systemctl enable --quiet --now report-builder.service message-broker.service
true
