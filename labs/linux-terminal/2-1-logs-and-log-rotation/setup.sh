[ -e /var/log/webapp ] && refuse "/var/log/webapp already exists; task 2 creates it. Remove it and start the lab again."
if ! pkg_installed rsyslog; then
	pkg_install rsyslog
	state_set installed-rsyslog 1
fi
systemctl enable --now --quiet rsyslog
ls /etc/logrotate.d >"$LAB_STATE/logrotate-d"
user_add alice

# Four commands as alice with sudo, a second apart; the last three are the
# answer to task 1.
cat >/etc/sudoers.d/le-lab-alice <<'X'
alice ALL=(root) NOPASSWD: /usr/bin/ls /etc/apt, /usr/bin/cat /etc/hostname, /usr/bin/du -sh /var/log, /usr/bin/tail -n 5 /var/log/dpkg.log
X
chmod 440 /etc/sudoers.d/le-lab-alice
for c in "/usr/bin/ls /etc/apt" "/usr/bin/cat /etc/hostname" "/usr/bin/du -sh /var/log" "/usr/bin/tail -n 5 /var/log/dpkg.log"; do
	runuser -u alice -- sudo -n $c >/dev/null 2>&1 || true
	sleep 1
done
rm -f /etc/sudoers.d/le-lab-alice

# Messages for task 3, from notice to critical.
logger -t webapp -p user.notice "cache warmed in 840 ms"
logger -t webapp -p user.warning "disk use at 85 percent on /var"
logger -t webapp -p user.err "cannot connect to database at 10.0.0.5:5432"
logger -t webapp -p user.crit "all worker threads stuck, giving up"
true
