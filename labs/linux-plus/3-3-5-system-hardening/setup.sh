listening 2323 tcp && refuse "something already listens on port 2323, which the lab uses; stop it and start again"
findmnt /mnt/nx >/dev/null && refuse "/mnt/nx is already mounted; unmount it and start again"
command -v setcap >/dev/null || pkg_install libcap/libcap2-bin

# Task 1: a service listening on TCP 2323.
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/legacyd.py <<'Y'
# Accepts connections on TCP port 2323, says hello and hangs up.
import socket
open("/proc/self/comm", "w").write("legacyd")
s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("0.0.0.0", 2323))
s.listen()
while True:
    c, _ = s.accept()
    c.sendall(b"legacy remote console\r\n")
    c.close()
Y
cat >/etc/systemd/system/legacy-console.service <<'Y'
[Unit]
Description=Legacy remote console
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/legacyd.py

[Install]
WantedBy=multi-user.target
Y
systemctl daemon-reload
systemctl enable --now --quiet legacy-console.service

# Task 2: a setuid program no package installed (a copy of id: harmless).
install -m 4755 -o root -g root /usr/bin/id /usr/local/bin/sysreport
# Task 3: a program with a file capability.
install -m 755 /usr/bin/true /usr/sbin/netprobe
setcap cap_net_raw+ep /usr/sbin/netprobe
true
