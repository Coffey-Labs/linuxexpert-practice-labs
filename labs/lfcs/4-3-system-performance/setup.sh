pkg_install stress-ng sysstat

# Task 5's evidence should survive a reboot.
if [ ! -d /var/log/journal ]; then
	mkdir -p /var/log/journal
	systemd-tmpfiles --create --prefix /var/log/journal
	journalctl --flush
	state_set made-journal 1
fi

# Tasks 1 and 2: a service that keeps one CPU busy.
cat >/etc/systemd/system/index-builder.service <<'X'
[Unit]
Description=Search index builder

[Service]
ExecStart=/usr/bin/stress-ng --cpu 1 --quiet

[Install]
WantedBy=multi-user.target
X

# Task 3: one slow unit off the critical path, and one on it.
cat >/etc/systemd/system/cache-warmup.service <<'X'
[Unit]
Description=Warm the report cache
DefaultDependencies=no
After=sysinit.target

[Service]
Type=oneshot
ExecStart=/bin/sleep 30
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/inventory-sync.service <<'X'
[Unit]
Description=Sync the inventory before logins
Before=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/sleep 12
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --quiet cache-warmup.service inventory-sync.service
systemctl enable --quiet --now index-builder.service

# Task 4: collection off.
if is_rhel; then
	systemctl disable --quiet --now sysstat.service sysstat-collect.timer sysstat-summary.timer 2>/dev/null || true
else
	sed -i 's/^ENABLED=.*/ENABLED="false"/' /etc/default/sysstat
fi
