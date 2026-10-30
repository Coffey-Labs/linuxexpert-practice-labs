pkg_installed tuned || pkg_install tuned
state_set was-enabled "$(systemctl is-enabled tuned 2>/dev/null)"
state_set was-active "$(systemctl is-active tuned 2>/dev/null)"
[ -f /etc/tuned/active_profile ] && cp -a /etc/tuned/active_profile "$LAB_STATE/active_profile"
[ -f /etc/tuned/profile_mode ] && cp -a /etc/tuned/profile_mode "$LAB_STATE/profile_mode"
systemctl enable --now --quiet tuned
rec=$(tuned-adm recommend 2>/dev/null)
[ -n "$rec" ] || die "tuned-adm recommend printed nothing"
start=balanced
[ "$rec" = balanced ] && start=throughput-performance
tuned-adm profile "$start"
sleep 2
# Tasks 1 and 3 look in tuned's log after this point.
state_set log-offset "$(stat -c %s /var/log/tuned/tuned.log 2>/dev/null || echo 0)"
