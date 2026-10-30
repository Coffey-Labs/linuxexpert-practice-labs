LOG=$LAB_STATE/watch.log SETUP_BOOT=$(state_get setup-boot)
seen() { grep -Eq "$1" "$LOG" 2>/dev/null; }

task 1 "httpd installed, enabled and running after a reboot"
need "httpd is installed" pkg_installed httpd
need "httpd ran enabled after a reboot since the lab started" 'awk -v b="$SETUP_BOOT" "\$1 != b && \$2 == \"enabled\" && \$3 == \"active\" {f = 1} END {exit !f}" "$LOG"'

task 2 "httpd stopped and masked"
need "httpd was masked while stopped" 'seen " masked (inactive|failed)$"'

task 3 "httpd unmasked, stopped and disabled"
need "httpd was masked before (task 2)" 'seen " masked "'
need "systemctl is-enabled httpd prints disabled" '[ "$(systemctl is-enabled httpd 2>/dev/null)" = disabled ]'
need "systemctl is-active httpd prints inactive" '[ "$(systemctl is-active httpd 2>/dev/null)" = inactive ]'
