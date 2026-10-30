listening 9100 tcp && refuse "something already listens on port 9100, which the lab uses; stop it and start again"
listening 8443 tcp && refuse "something already listens on port 8443, which the lab uses; stop it and start again"
peer_up
mkdir -p /usr/local/lib/le-lab /etc/le-lab/tls

# Task 1: a service on all addresses.
echo 'LISTEN=0.0.0.0' >/etc/metrics-exporter.conf
cat >/usr/local/lib/le-lab/metrics-exporter.py <<'Y'
# Serves a few made-up metrics on the address in /etc/metrics-exporter.conf.
import http.server, socketserver
addr = "127.0.0.1"
for line in open("/etc/metrics-exporter.conf"):
    if line.strip().startswith("LISTEN="):
        addr = line.split("=", 1)[1].strip()


class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"node_load1 0.42\nnode_users 3\n")


class S(http.server.HTTPServer):
    allow_reuse_address = True

    def server_bind(self):
        socketserver.TCPServer.server_bind(self)


S((addr, 9100), H).serve_forever()
Y
cat >/etc/systemd/system/metrics-exporter.service <<'Y'
[Unit]
Description=Metrics exporter for local monitoring
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/metrics-exporter.py

[Install]
WantedBy=multi-user.target
Y

# Task 2: a CA, and a server certificate for the wrong name.
cd /etc/le-lab/tls
openssl req -x509 -newkey rsa:2048 -nodes -keyout ca.key -out ca.crt -days 30 -subj "/CN=Lab Test CA" 2>/dev/null
openssl req -new -newkey rsa:2048 -nodes -keyout server.key -out server.csr -subj "/CN=old.example.test" 2>/dev/null
printf 'subjectAltName=DNS:old.example.test\n' >san.ext
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 30 -extfile san.ext 2>/dev/null
rm -f server.csr san.ext
chmod 600 ca.key server.key
cd /
cat >/etc/systemd/system/le-lab-tls.service <<'Y'
[Unit]
Description=Practice lab TLS test server on port 8443
After=network.target

[Service]
ExecStart=/usr/bin/openssl s_server -accept 8443 -cert /etc/le-lab/tls/server.crt -key /etc/le-lab/tls/server.key -www -quiet

[Install]
WantedBy=multi-user.target
Y
systemctl daemon-reload
systemctl enable --now --quiet metrics-exporter.service le-lab-tls.service

# Task 3: the SSH client insists on a key exchange the server dropped.
cat >/etc/ssh/ssh_config.d/05-legacy-hosts.conf <<'Y'
# Settings for old appliances.
Host localhost 127.0.0.1
    KexAlgorithms diffie-hellman-group1-sha1
Y

# Task 4: a repository that doesn't exist.
if is_rhel; then
	printf '[internal-tools]\nname=Internal tools\nbaseurl=https://repo.example.invalid/el10/\ngpgcheck=1\n' >/etc/yum.repos.d/internal-tools.repo
fi
true
