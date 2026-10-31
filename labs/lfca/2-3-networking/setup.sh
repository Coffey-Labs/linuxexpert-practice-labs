IF=$(ip -4 route show default | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
[ -n "$IF" ] || refuse "no default route; this lab needs a working network"
state_set if "$IF"
user_add alice
ls -d /root/.ssh/id_* >"$LAB_STATE/root-keys" 2>/dev/null || true

# Packages the tasks install: reset removes the ones that weren't here.
for p in $(pick bind-utils bind9-dnsutils) $(pick firewalld ''); do
	pkg_installed "$p" || echo "$p" >>"$LAB_STATE/not-installed"
done

# The firewall as it is, and a starting point with port 8080 open.
if is_rhel; then
	if pkg_installed firewalld; then
		tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
		enabled firewalld && state_set firewalld-was-enabled 1
	fi
	if active firewalld; then
		state_set firewalld-was-active 1
		z=$(firewall-cmd --get-zone-of-interface="$IF" 2>/dev/null || firewall-cmd --get-default-zone)
		firewall-cmd -q --permanent --zone="$z" --add-port=8080/tcp
		firewall-cmd -q --reload
	fi
else
	tar -C /etc -cf "$LAB_STATE/ufw.tar" ufw default/ufw
	if ufw status | grep -q 'Status: active'; then
		state_set ufw-was-active 1
		ufw allow 8080/tcp >/dev/null
	fi
fi

# The web server on 8080, and the peer.
peer_up
mkdir -p /usr/local/lib/le-lab /srv/le-app
echo 'Lab web server on port 8080' >/srv/le-app/index.html
cat >/usr/local/lib/le-lab/httpd.py <<'X'
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
X
cat >/etc/systemd/system/le-lab-app.service <<'X'
[Unit]
Description=Practice lab web server on port 8080
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/httpd.py 8080 --directory /srv/le-app

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-app.service
