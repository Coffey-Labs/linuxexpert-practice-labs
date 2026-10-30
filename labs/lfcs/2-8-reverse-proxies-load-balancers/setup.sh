peer_up
for p in nginx haproxy; do
	if pkg_installed $p && [ -d /etc/$p ]; then
		state_set had-$p 1
		tar -C /etc -cf "$LAB_STATE/$p.tar" $p
	fi
done
command -v getenforce >/dev/null && state_set selinux "$(getenforce)"
command -v getsebool >/dev/null && state_set httpd-connect "$(getsebool httpd_can_network_connect | awk '{print $3}')"

mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/backend.py <<'X'
# A practice lab back end: answers every request with a page naming it,
# and logs (and saves) the X-Forwarded-For header it gets.
import http.server, os, socketserver, sys

port = int(sys.argv[1])
state = "/run/le-backend"
os.makedirs(state, exist_ok=True)


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        xff = self.headers.get("X-Forwarded-For")
        if xff is not None:
            with open(f"{state}/{port}.xff", "w") as f:
                f.write(xff + "\n")
        body = f"Back end {port}\n".encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        xff = self.headers.get("X-Forwarded-For", "-") if hasattr(self, "headers") else "-"
        sys.stderr.write(f"{self.address_string()} {fmt % args} X-Forwarded-For: {xff}\n")


class Server(http.server.ThreadingHTTPServer):
    # Without HTTPServer's reverse DNS lookup of the address.
    def server_bind(self):
        socketserver.TCPServer.server_bind(self)
        self.server_name, self.server_port = self.server_address[:2]


Server(("127.0.0.1", port), Handler).serve_forever()
X
cat >/etc/systemd/system/le-backend@.service <<'X'
[Unit]
Description=Practice lab back end on port %i
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/backend.py %i

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-backend@8081 le-backend@8082 le-backend@8083

# Save the firewall's configuration, if one runs, for reset.
if systemctl is-active --quiet firewalld; then
	tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
elif command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
	tar -C /etc -cf "$LAB_STATE/ufw.tar" ufw
fi
