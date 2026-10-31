id erin >/dev/null 2>&1 && refuse "user erin already exists; remove it first (userdel -r erin)"
for p in /root/add-dev.sh /root/ansible /srv/erin; do
	[ ! -e "$p" ] || refuse "$p already exists; move it away first"
done
getent group developers >/dev/null || { groupadd developers; state_set made-developers 1; }
[ -e /root/.ansible ] && state_set had-dot-ansible 1

# Packages the tasks install: reset removes the ones that weren't here.
for p in $(pick ansible-core ansible) nginx; do
	pkg_installed "$p" || echo "$p" >>"$LAB_STATE/not-installed"
done
if pkg_installed nginx; then
	enabled nginx && state_set nginx-was-enabled 1
	active nginx && state_set nginx-was-active 1
fi

# The service nobody needs.
mkdir -p /usr/local/lib/le-lab /srv/le-oldapp
echo 'Old intranet app' >/srv/le-oldapp/index.html
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
cat >/etc/systemd/system/le-lab-oldapp.service <<'X'
[Unit]
Description=Old intranet app (practice lab)
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/httpd.py 7070 --directory /srv/le-oldapp

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-oldapp.service
