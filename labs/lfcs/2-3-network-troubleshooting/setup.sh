pkg_install dnsmasq/dnsmasq-base
peer_up

# The peer's network settings, broken on purpose: a gateway that doesn't
# exist, and a DNS server that doesn't either.
mkdir -p /etc/netns/lepeer
cat >/etc/netns/lepeer/network <<'X'
# The peer's network settings, applied inside the peer at every boot with
# "ip -batch" (each line is an ip command without the leading "ip").
address replace 10.99.0.2/24 dev le-peer
route replace default via 10.99.0.254
X
echo 'nameserver 198.51.100.35' >/etc/netns/lepeer/resolv.conf

# The far side: 198.51.100.9 and the DNS server 198.51.100.53, on the VM.
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/trouble-net.sh <<'X'
#!/bin/sh
ip link show le-far >/dev/null 2>&1 || ip link add le-far type dummy
ip addr replace 198.51.100.9/32 dev le-far
ip addr replace 198.51.100.53/32 dev le-far
ip link set le-far up
ip -n lepeer -force -batch /etc/netns/lepeer/network
true
X
chmod 755 /usr/local/lib/le-lab/trouble-net.sh
if [ -d /etc/NetworkManager/conf.d ]; then
	printf '[keyfile]\nunmanaged-devices=interface-name:le-host;interface-name:le-far\n' \
		>/etc/NetworkManager/conf.d/91-le-lab-trouble.conf
	systemctl reload NetworkManager 2>/dev/null || true
fi

# A web server that listens on 127.0.0.1 only (task 3), and a process on
# UDP port 8125 (task 5).
mkdir -p /srv/le-web
echo 'Lab web server on the VM' >/srv/le-web/index.html
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
cat >/usr/local/lib/le-lab/metricsd.py <<'X'
# Listens on UDP port 8125 and throws away what it gets.
import select, socket
open("/proc/self/comm", "w").write("metricsd")
socks = []
for addr in ("127.0.0.1", "10.99.0.1"):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.bind((addr, 8125))
    socks.append(s)
while True:
    for s in select.select(socks, [], [])[0]:
        s.recv(65535)
X

cat >/etc/systemd/system/le-lab-trouble.service <<'X'
[Unit]
Description=Practice lab: the peer's network settings
Requires=le-lab-peer.service
After=le-lab-peer.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/lib/le-lab/trouble-net.sh

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/le-lab-dns.service <<'X'
[Unit]
Description=Practice lab DNS server at 198.51.100.53
Requires=le-lab-trouble.service
After=le-lab-trouble.service

[Service]
ExecStart=/usr/sbin/dnsmasq -k --conf-file=/dev/null --pid-file= --bind-interfaces --listen-address=198.51.100.53

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/le-lab-web.service <<'X'
[Unit]
Description=Practice lab web server
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/httpd.py 80 --bind 127.0.0.1 --directory /srv/le-web

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/le-lab-metricsd.service <<'X'
[Unit]
Description=Practice lab metrics collector
Requires=le-lab-peer.service
After=le-lab-peer.service

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/metricsd.py

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-trouble.service le-lab-dns.service le-lab-web.service le-lab-metricsd.service

# A firewall on this VM isn't part of the puzzle: trust the lab network.
if systemctl is-active --quiet firewalld; then
	firewall-cmd -q --zone=trusted --add-interface=le-host
	firewall-cmd -q --permanent --zone=trusted --add-interface=le-host
	firewall-cmd -q --zone=trusted --add-interface=le-far
	firewall-cmd -q --permanent --zone=trusted --add-interface=le-far
elif command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
	ufw allow in on le-host >/dev/null
	state_set ufw 1
fi
true
