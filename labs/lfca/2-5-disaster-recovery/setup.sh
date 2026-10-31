for p in /srv/projects /srv/site /root/projects.tar.gz; do
	[ ! -e "$p" ] || refuse "$p already exists; move it away first"
done
pkg_installed rsync || state_set no-rsync 1
user_add alice

# What task 1 backs up.
mkdir -p /srv/projects/src /srv/projects/docs
echo 'Project plan: move the team to the new file server.' >/srv/projects/plan.txt
printf 'print("hello")\n' >/srv/projects/src/app.py
seq 1 500 | sed 's/^/Note /' >/srv/projects/docs/notes.md
(cd /srv && find projects -type f -exec sha256sum {} + | sort -k2) >"$LAB_STATE/projects.sha"
state_set projects-id "$(stat -c "%i %.9W" /srv/projects)"

# What task 2 mirrors.
mkdir -p /srv/site/images
echo '<h1>Our shop</h1>' >/srv/site/index.html
echo '<h1>About us</h1>' >/srv/site/about.html
head -c 2M /dev/urandom >/srv/site/images/banner.bin
state_set index-sha "$(sha256sum </srv/site/index.html)"

# The peer and its sshd.
peer_up
cat >/etc/systemd/system/le-lab-peer-sshd.service <<'X'
[Unit]
Description=Practice lab sshd on the peer
Requires=le-lab-peer.service
After=le-lab-peer.service network.target

[Service]
NetworkNamespacePath=/run/netns/lepeer
ExecStartPre=/bin/mkdir -p /run/sshd
ExecStart=/usr/sbin/sshd -D -o ListenAddress=10.99.0.2:22 -o PidFile=none
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
X
systemctl daemon-reload
systemctl enable --now --quiet le-lab-peer-sshd.service
