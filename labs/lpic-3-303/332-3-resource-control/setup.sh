id limited >/dev/null 2>&1 && refuse "a user called limited already exists; remove it and start again"
[ -e /sys/fs/cgroup/lab ] && refuse "/sys/fs/cgroup/lab already exists; remove it and start again"
ls /etc/systemd/system.control/lab.slice.d /etc/systemd/system/lab.slice.d >/dev/null 2>&1 && refuse "lab.slice already has drop-ins; remove them and start again"
[ -f /sys/fs/cgroup/cgroup.controllers ] || refuse "this lab needs cgroup v2 (the unified hierarchy)"
ls /etc/security/limits.d >"$LAB_STATE/limits-d" 2>/dev/null || true
user_add limited
true
