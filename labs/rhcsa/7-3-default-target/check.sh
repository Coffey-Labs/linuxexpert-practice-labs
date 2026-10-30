LOG=$LAB_STATE/watch.log SETUP_BOOT=$(state_get setup-boot)
BOOT=$(cat /proc/sys/kernel/random/boot_id)

task 1 "Default switched to graphical.target, then back to multi-user.target"
need "the default was graphical.target at some point" 'grep -q " .*/graphical\.target$" "$LOG"'
need "after that it was multi-user.target again" 'awk "/\/graphical\.target\$/ {g = 1} g && /\/multi-user\.target\$/ {m = 1} END {exit !m}" "$LOG"'

task 2 "Rebooted with multi-user.target as the default"
need "systemctl get-default prints multi-user.target" '[ "$(systemctl get-default)" = multi-user.target ]'
need "the system has rebooted since the lab started" '[ "$BOOT" != "$SETUP_BOOT" ]'
need "this boot started with multi-user.target as the default" 'awk -v b="$BOOT" "\$1 == b {print \$2; exit}" "$LOG" | grep -q "/multi-user\.target$"'
need "graphical.target isn't active" '! systemctl is-active --quiet graphical.target'
