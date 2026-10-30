mkdir -p /run/sshd
sshd -T 2>/dev/null | grep -qx 'passwordauthentication yes' ||
	refuse "sshd doesn't allow password logins, which task 1 uses; allow them and start again"
listening 9090 tcp && refuse "something already listens on port 9090, which the lab uses; stop it and start again"
user_add kim
tar -C /etc -cf "$LAB_STATE/ssh.tar" ssh
peer_up

# A web service on 127.0.0.1:9090 only, standing in for Cockpit.
mkdir -p /srv/le-console /usr/local/lib/le-lab
echo 'Lab console on port 9090' >/srv/le-console/index.html
cat >/usr/local/lib/le-lab/httpd.py <<'Y'
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
Y
cat >/etc/systemd/system/le-lab-console.service <<'Y'
[Unit]
Description=Practice lab web service on 127.0.0.1:9090
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/httpd.py 9090 --bind 127.0.0.1 --directory /srv/le-console

[Install]
WantedBy=multi-user.target
Y
systemctl daemon-reload
systemctl enable --now --quiet le-lab-console.service
