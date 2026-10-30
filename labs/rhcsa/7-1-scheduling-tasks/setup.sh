user_add alice
pkg_installed cronie || pkg_install cronie
systemctl enable --quiet --now crond
crontab -u alice -r >/dev/null 2>&1 || true
rm -f /tmp/at-ran
state_set start "$(date +%s)"
# How many at jobs were made before the lab.
seq=$(cat /var/spool/at/.SEQ 2>/dev/null | head -n1)
state_set at-seq "$((16#${seq:-0}))"
ls /etc/systemd/system/*.timer >"$LAB_STATE/timers-before" 2>/dev/null || true
