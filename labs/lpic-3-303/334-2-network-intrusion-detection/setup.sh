listening 3000 tcp && refuse "something already listens on port 3000; stop it and start again"
[ -e /root/snort-console.txt ] && refuse "/root/snort-console.txt already exists; move it away and start again"
# Reset removes every package installed from here on, by setup or by the
# tasks, and only those.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
pkgs_now >"$LAB_STATE/pkgs-before"
for d in etc/snort etc/ntopng.conf; do [ -e /$d ] && printf '%s\n' "$d" >>"$LAB_STATE/saved"; done
[ -s "$LAB_STATE/saved" ] && tar -C / -cf "$LAB_STATE/conf.tar" $(cat "$LAB_STATE/saved")
for s in snort ntopng; do active $s && printf '%s\n' $s >>"$LAB_STATE/active"; done
peer_up
# Snort's installer lists every interface that's up, including the lab's
# "le-host@ifN", which it can't use, and then fails. With its Debian
# configuration file already there, it takes the interface from that.
if ! pkg_installed snort && [ ! -e /etc/snort/snort.debian.conf ]; then
	IF=$(ip -4 route show default | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')
	mkdir -p /etc/snort
	printf 'DEBIAN_SNORT_INTERFACE="%s"\n' "${IF:-eth0}" >/etc/snort/snort.debian.conf
fi

# The web server on 10.99.0.1:8080, with a large file.
mkdir -p /srv/le-app /usr/local/lib/le-lab
echo ok >/srv/le-app/index.html
head -c 50M /dev/urandom >/srv/le-app/big.bin
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
cat >/etc/systemd/system/le-lab-app.service <<'X'
[Unit]
Description=Practice lab web server on 10.99.0.1:8080
Requires=le-lab-peer.service
After=le-lab-peer.service

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/httpd.py 8080 --bind 10.99.0.1 --directory /srv/le-app

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-app.service
