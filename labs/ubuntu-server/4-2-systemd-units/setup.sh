pkg_installed apport || refuse "apport isn't installed (task 3 masks it); install it with: sudo apt install apport"
[ "$(systemctl is-enabled apport 2>/dev/null)" = enabled ] || refuse "apport.service isn't enabled; run: sudo systemctl unmask apport; sudo systemctl enable apport"
[ -e /etc/systemd/system/inventory-sync.service ] && refuse "/etc/systemd/system/inventory-sync.service already exists; move it away and start again"
ls /etc/systemd/system >"$LAB_STATE/units-before"
cat >/etc/systemd/system/inventory-sync.service <<'X'
[Unit]
Description=Inventory sync agent
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/opt/inventory/bin/inventory-sync --daemon

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --quiet inventory-sync.service
systemctl start inventory-sync.service 2>/dev/null || true
