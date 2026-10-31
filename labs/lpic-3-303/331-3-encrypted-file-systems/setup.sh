[ -e /dev/mapper/secret ] && refuse "a device-mapper device called secret already exists; close it and start again"
findmnt /mnt/secret >/dev/null && refuse "something is mounted on /mnt/secret; unmount it and start again"
grep -Eqs '^[[:space:]]*secret[[:space:]]' /etc/crypttab && refuse "/etc/crypttab already has an entry called secret; remove it and start again"
[ -e /root/secret.key ] && refuse "/root/secret.key already exists; move it away and start again"
# Reset removes every package installed from here on, by setup or by the
# tasks, and only those.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
pkgs_now >"$LAB_STATE/pkgs-before"
cp -a /etc/fstab "$LAB_STATE/fstab"
[ -f /etc/crypttab ] && cp -a /etc/crypttab "$LAB_STATE/crypttab"

disk_add 0 512M >/dev/null
is_debian && user_add crypto

# The peer's Tang server: its own keys, on the peer's port 80.
pkg_install tang
systemctl disable --now --quiet tangd.socket 2>/dev/null || true
K=$(pick /var/db/tang /var/lib/tang)
mkdir -p $K
ls $K/*.jwk >/dev/null 2>&1 || /usr/libexec/tangd-keygen $K
peer_up
cat >/etc/systemd/system/le-lab-peer-tang.socket <<'X'
[Unit]
Description=Practice lab Tang server on the peer
DefaultDependencies=no
Requires=le-lab-peer.service
After=le-lab-peer.service

[Socket]
NetworkNamespacePath=/run/netns/lepeer
ListenStream=10.99.0.2:80
Accept=yes

[Install]
WantedBy=multi-user.target
X
cat >/etc/systemd/system/le-lab-peer-tang@.service <<X
[Unit]
Description=Practice lab Tang server on the peer (connection)

[Service]
StandardInput=socket
StandardOutput=socket
StandardError=journal
ExecStart=/usr/libexec/tangd $K
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-peer-tang.socket
