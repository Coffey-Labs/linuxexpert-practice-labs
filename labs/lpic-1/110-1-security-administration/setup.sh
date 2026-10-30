[ -e /usr/local/bin/testbash ] && refuse "/usr/local/bin/testbash exists already; remove it first"
for u in tess locky; do
	id "$u" >/dev/null 2>&1 && refuse "user $u exists already; remove it first (userdel -r $u)"
done
user_add tess
user_add locky
state_set since "$(date '+%Y-%m-%d %H:%M:%S')"
ls /etc/sudoers.d >"$LAB_STATE/sudoers-d" 2>/dev/null || true
ls /etc/security/limits.d >"$LAB_STATE/limits-d" 2>/dev/null || true
cp -a /etc/security/limits.conf "$LAB_STATE/limits.conf"

# labweb, a service for task 4, and backupd, a program on TCP port 9999.
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/backupd.py <<'X'
# Listens on TCP port 9999 and closes every connection at once.
import socket
open("/proc/self/comm", "w").write("backupd")
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("0.0.0.0", 9999))
s.listen(5)
while True:
    c, _ = s.accept()
    c.close()
X
cat >/etc/systemd/system/labweb.service <<'X'
[Unit]
Description=Practice lab web service (does nothing)

[Service]
ExecStart=/bin/sleep infinity

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/le-lab-backupd.service <<'X'
[Unit]
Description=Practice lab program on TCP port 9999
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/backupd.py

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet labweb.service le-lab-backupd.service

# The peer, and a firewall that lets it in.
peer_up
if systemctl is-active --quiet firewalld; then
	firewall-cmd -q --zone=trusted --add-interface=le-host
	firewall-cmd -q --permanent --zone=trusted --add-interface=le-host
elif command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
	ufw allow in on le-host >/dev/null
	state_set ufw 1
fi
true
