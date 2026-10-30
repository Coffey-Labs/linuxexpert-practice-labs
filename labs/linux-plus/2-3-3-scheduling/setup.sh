cron=$(pick crond cron)
if ! pkg_installed "$(pick cronie cron)"; then pkg_install cronie/cron; fi
systemctl enable --now --quiet "$cron"
pkg_installed at && state_set had-at 1
if systemctl is-active --quiet atd; then state_set atd-active 1; fi
rm -f /tmp/cron-test.txt /tmp/cron-env.txt /tmp/at-ran
