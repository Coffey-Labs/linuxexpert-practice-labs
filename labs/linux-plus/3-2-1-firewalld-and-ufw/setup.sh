IF=$(ip -4 route show default | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
[ -n "$IF" ] || refuse "no default route; this lab needs a working network"
state_set if "$IF"
peer_up
ip -n lepeer addr add 10.99.0.3/24 dev le-peer 2>/dev/null || true

if is_rhel; then
	pkg_install firewalld nftables
	pkg_installed firewalld && systemctl is-active --quiet firewalld && state_set firewalld-was-active 1
	tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
	systemctl enable --now --quiet firewalld
	firewall-cmd -q --state
	z=$(firewall-cmd --get-zone-of-interface="$IF" 2>/dev/null || firewall-cmd --get-default-zone)
	# The starting point: SSH allowed, HTTP not.
	firewall-cmd -q --permanent --zone="$z" --query-service=ssh || firewall-cmd -q --permanent --zone="$z" --add-service=ssh
	firewall-cmd -q --permanent --zone="$z" --query-service=http && firewall-cmd -q --permanent --zone="$z" --remove-service=http
	firewall-cmd -q --reload
else
	ufw status | grep -q 'Status: active' && state_set ufw-was-active 1
	tar -C /etc -cf "$LAB_STATE/ufw.tar" ufw default/ufw
	if [ -n "$(state_get ufw-was-active)" ]; then
		ufw --force reset >/dev/null
		ufw --force disable >/dev/null
	fi
fi

# Web services on 8080 and 9000.
mkdir -p /srv/le-app /usr/local/lib/le-lab
echo 'Lab app' >/srv/le-app/index.html
cat >/usr/local/lib/le-lab/httpd.py <<'Y'
# A static web server like "python3 -m http.server PORT --directory DIR",
# without its reverse DNS lookup of the address, which can take seconds.
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
Y
for p in 8080 9000; do
	cat >/etc/systemd/system/le-lab-app$p.service <<Y
[Unit]
Description=Practice lab web service on port $p
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/httpd.py $p --directory /srv/le-app

[Install]
WantedBy=multi-user.target
Y
done
systemctl daemon-reload
systemctl enable --now --quiet le-lab-app8080.service le-lab-app9000.service
