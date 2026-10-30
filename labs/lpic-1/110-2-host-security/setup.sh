[ -e /etc/nologin ] && refuse "/etc/nologin exists, so nobody but root can log in; remove it first"
for u in tess testuser; do
	id "$u" >/dev/null 2>&1 && refuse "user $u exists already; remove it first (userdel -r $u)"
done
user_add tess
user_add testuser
state_set since "$(date '+%Y-%m-%d %H:%M:%S')"
# Where logins are logged, and how much is there already: the journal may
# not last across a reboot.
for f in /var/log/secure /var/log/auth.log; do
	[ -f "$f" ] && state_set "size$(echo "$f" | tr / _)" "$(stat -c %s "$f")"
done
# tess logs in with a key.
mkdir -p /root/lab-keys
chmod 700 /root/lab-keys
rm -f /root/lab-keys/tess /root/lab-keys/tess.pub
ssh-keygen -q -t ed25519 -N '' -C tess@lab -f /root/lab-keys/tess
h=$(getent passwd tess | cut -d: -f6)
install -d -m 700 -o tess -g tess "$h/.ssh"
install -m 600 -o tess -g tess /root/lab-keys/tess.pub "$h/.ssh/authorized_keys"
command -v restorecon >/dev/null && restorecon -R "$h/.ssh"

# legacy-echo: an echo service on TCP port 7007.
mkdir -p /usr/local/lib/le-lab
cat >/usr/local/lib/le-lab/legacy-echo.py <<'X'
# Echoes back whatever it gets on TCP port 7007.
import socketserver


class Echo(socketserver.StreamRequestHandler):
    def handle(self):
        for line in self.rfile:
            self.wfile.write(line)


socketserver.ThreadingTCPServer.allow_reuse_address = True
socketserver.ThreadingTCPServer(("0.0.0.0", 7007), Echo).serve_forever()
X
# In /usr/local/lib/systemd/system, so that it can be masked.
mkdir -p /usr/local/lib/systemd/system
cat >/usr/local/lib/systemd/system/legacy-echo.service <<'X'
[Unit]
Description=Legacy echo service on TCP port 7007
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/lib/le-lab/legacy-echo.py

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet legacy-echo.service
true
