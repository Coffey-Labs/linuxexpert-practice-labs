# Tunnels and other listeners on port 8000.
for pid in $(ss -Htlnp 'sport = :8000' | grep -o 'pid=[0-9]*' | cut -d= -f2 | sort -u); do
	kill "$pid" 2>/dev/null
done
systemctl disable --now --quiet le-lab-peer-sshd.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-peer-sshd.service
systemctl daemon-reload
rm -rf /etc/netns/lepeer/ssh
rmdir /etc/netns/lepeer /etc/netns 2>/dev/null
rm -f /tmp/alice.asc /tmp/bob.asc /tmp/secret.txt.gpg
users_remove
true
