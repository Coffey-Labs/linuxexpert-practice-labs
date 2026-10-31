for p in 80 5432; do
	ss -Hltn "sport = :$p" | grep -q . && refuse "something already listens on port $p; stop it and start again"
done
u=${SUDO_USER:-root}
h=$(getent passwd "$u" | cut -d: -f6)
for f in "$h/check.sh" /root/check.sh; do
	[ -e "$f" ] && refuse "$f already exists (task 1 writes it); move it away and start again"
done
state_set student "$u"
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/listener.py <<'X'
# A TCP listener with its own program name: listener.py NAME ADDRESS PORT.
import socket, sys

name, addr, port = sys.argv[1], sys.argv[2], int(sys.argv[3])
with open("/proc/self/comm", "w") as f:
    f.write(name)
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((addr, port))
s.listen(16)
while True:
    c, _ = s.accept()
    c.close()
X
mk() {
	cat >/etc/systemd/system/le-lab-$1.service <<X
[Unit]
Description=Practice lab listener $1
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/listener.py $1 $2 $3

[Install]
WantedBy=multi-user.target
X
}
mk intranetd 0.0.0.0 80
mk reportdb 127.0.0.1 5432
systemctl daemon-reload
systemctl enable --now --quiet le-lab-intranetd.service le-lab-reportdb.service
