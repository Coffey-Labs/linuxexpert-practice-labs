pkg_installed tree && refuse "tree is installed; remove it first (the playbook installs it)"
user_add alice -G "$(pick wheel sudo)"
pkg_installed at && state_set had-at 1
pkg_installed at || pkg_install at
enabled atd && state_set atd-enabled 1
systemctl disable --now --quiet atd 2>/dev/null
[ -e /etc/motd ] && cp -a /etc/motd "$LAB_STATE/motd"
systemctl enable --now --quiet "$(pick sshd ssh)" 2>/dev/null || true
