if pkg_installed nginx; then
	state_set had-nginx 1
	enabled nginx && state_set nginx-was-enabled 1
	active nginx && state_set nginx-was-active 1
	tar -C /etc -cf "$LAB_STATE/nginx.tar" nginx
fi
if command -v getsebool >/dev/null; then
	getsebool httpd_can_network_connect httpd_can_network_relay 2>/dev/null >"$LAB_STATE/sebools" || true
fi

# Two web servers in the peer.
peer_up
mkdir -p /usr/local/lib/le-lab /srv/le-backend1 /srv/le-backend2
echo 'Web server one' >/srv/le-backend1/index.html
echo 'Web server two' >/srv/le-backend2/index.html
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
for n in 1 2; do
	cat >/etc/systemd/system/le-lab-backend$n.service <<X
[Unit]
Description=Practice lab web server $n on the peer
Requires=le-lab-peer.service
After=le-lab-peer.service

[Service]
NetworkNamespacePath=/run/netns/lepeer
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/httpd.py 808$n --bind 10.99.0.2 --directory /srv/le-backend$n

[Install]
WantedBy=multi-user.target
X
done
systemctl daemon-reload
systemctl enable --now --quiet le-lab-backend1.service le-lab-backend2.service
