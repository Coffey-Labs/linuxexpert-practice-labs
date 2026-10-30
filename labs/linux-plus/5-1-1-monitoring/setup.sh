state_set start "$(date +%s)"
if [ ! -d /var/log/journal ]; then
	mkdir -p /var/log/journal
	systemd-tmpfiles --create --prefix /var/log/journal
	journalctl --flush
	state_set made-journal 1
fi
for f in /etc/snmp/snmpd.conf; do [ -f $f ] && cp -a $f "$LAB_STATE/snmpd.conf"; done
pkg_installed net-snmp && state_set had-snmpd 1
pkg_installed snmpd && state_set had-snmpd 1
peer_up

mkdir -p /srv/le-web /usr/local/lib/le-lab
echo 'Lab web service' >/srv/le-web/index.html
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
cat >/etc/systemd/system/le-lab-web.service <<'Y'
[Unit]
Description=Practice lab web service on 127.0.0.1:8080
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/httpd.py 8080 --bind 127.0.0.1 --directory /srv/le-web

[Install]
WantedBy=multi-user.target
Y
systemctl daemon-reload
systemctl enable --now --quiet le-lab-web.service
if systemctl is-active --quiet firewalld; then
	firewall-cmd -q --query-service=snmp && state_set snmp-open 1
	firewall-cmd -q --permanent --query-service=snmp && state_set snmp-open-permanent 1
fi
true
