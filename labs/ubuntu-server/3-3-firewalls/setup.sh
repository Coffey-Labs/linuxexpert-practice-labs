command -v ufw >/dev/null || refuse "ufw isn't installed; install it with: sudo apt install ufw"
pkg_installed iptables-persistent && refuse "iptables-persistent is installed, which replaces ufw; remove it (sudo apt purge iptables-persistent), install ufw, and start again"
ss -Hltn 'sport = :80' | grep -q . && refuse "something already listens on port 80; stop it and start again"
pkg_installed netcat-openbsd || pkg_install netcat-openbsd
# ufw's rules, saved for reset; then start with ufw off and no rules.
ufw status | grep -q 'Status: active' && state_set ufw-was-active 1
tar -C /etc -cf "$LAB_STATE/ufw.tar" ufw default/ufw
ufw --force reset >/dev/null
ufw --force disable >/dev/null
find /etc/ufw -maxdepth 1 -name '*.rules.[0-9]*' -delete
state_set ufwlog-size "$(stat -c %s /var/log/ufw.log 2>/dev/null || echo 0)"

peer_up
ip -n lepeer addr add 10.99.0.3/24 dev le-peer 2>/dev/null || true
mkdir -p /srv/le-web /srv/le-peer-web /usr/local/lib/le-lab /etc/netns/lepeer
echo 'Lab web server on s1' >/srv/le-web/index.html
echo 'Peer test page' >/srv/le-peer-web/index.html
cat >/usr/local/lib/le-lab/httpd.py <<'X'
# A static web server like "python3 -m http.server PORT --bind ADDRESS
# --directory DIR", without its reverse DNS lookup of the address, which
# can take seconds.
import argparse, functools, http.server, socketserver

ap = argparse.ArgumentParser()
ap.add_argument("port", type=int)
ap.add_argument("--bind", default="")
ap.add_argument("--directory", default=".")
a = ap.parse_args()


class Server(http.server.ThreadingHTTPServer):
    def server_bind(self):
        socketserver.TCPServer.server_bind(self)
        self.server_name, self.server_port = self.server_address[:2]


handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=a.directory)
Server((a.bind, a.port), handler).serve_forever()
X
cat >/etc/systemd/system/le-lab-web.service <<'X'
[Unit]
Description=Practice lab web server on port 80
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/httpd.py 80 --directory /srv/le-web

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/le-lab-peer-sshd.service <<'X'
[Unit]
Description=Practice lab sshd on the peer
Requires=le-lab-peer.service
After=le-lab-peer.service network.target

[Service]
NetworkNamespacePath=/run/netns/lepeer
ExecStartPre=/bin/mkdir -p /run/sshd
ExecStart=/usr/sbin/sshd -D -o ListenAddress=10.99.0.2:22 -o PidFile=none
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/le-lab-peer-web.service <<'X'
[Unit]
Description=Practice lab test web server on the peer
Requires=le-lab-peer.service
After=le-lab-peer.service

[Service]
NetworkNamespacePath=/run/netns/lepeer
ExecStartPre=-/usr/sbin/ip addr add 10.99.0.3/24 dev le-peer
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/httpd.py 8000 --bind 10.99.0.2 --directory /srv/le-peer-web

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/le-lab-peer-iptables.service <<'X'
[Unit]
Description=Practice lab: the peer's iptables rules
Requires=le-lab-peer.service
After=le-lab-peer.service
ConditionPathExists=/etc/netns/lepeer/iptables.rules

[Service]
Type=oneshot
RemainAfterExit=yes
NetworkNamespacePath=/run/netns/lepeer
ExecStart=/usr/sbin/iptables-restore /etc/netns/lepeer/iptables.rules

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-web.service le-lab-peer-sshd.service le-lab-peer-web.service
