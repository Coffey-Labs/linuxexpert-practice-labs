for p in 8080 8081 8888; do listening $p tcp && refuse "something already listens on port $p; stop it and start again"; done
[ -e /root/fw ] && refuse "/root/fw already exists; move it away and start again"
command -v nft >/dev/null && nft list table inet lab >/dev/null 2>&1 && refuse "an nftables table inet lab already exists; delete it and start again"
# Reset removes every package installed from here on, by setup or by the
# tasks, and only those.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
pkgs_now >"$LAB_STATE/pkgs-before"
# The firewall frontends would fight hand-made rules: stop them for now.
if systemctl is-active --quiet firewalld; then
	state_set firewalld-was-active 1
	systemctl stop firewalld
fi
if command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
	state_set ufw-was-active 1
	ufw --force disable >/dev/null
fi
peer_up

# The two web servers.
mkdir -p /srv/le-fw/a /srv/le-fw/b /usr/local/lib/le-lab
echo "site on 8080" >/srv/le-fw/a/index.html
echo "site on 8081" >/srv/le-fw/b/index.html
cat >/usr/local/lib/le-lab/httpd.py <<'X'
# A static web server like "python3 -m http.server PORT --bind ADDRESS
# --directory DIR", without its reverse DNS lookup of the address.
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
for x in 8080:a 8081:b; do
	cat >/etc/systemd/system/le-lab-web${x%:*}.service <<X
[Unit]
Description=Practice lab web server on 10.99.0.1:${x%:*}
Requires=le-lab-peer.service
After=le-lab-peer.service

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/httpd.py ${x%:*} --bind 10.99.0.1 --directory /srv/le-fw/${x#*:}

[Install]
WantedBy=multi-user.target
X
done
systemctl daemon-reload
systemctl enable --now --quiet le-lab-web8080.service le-lab-web8081.service
