G=/sys/fs/cgroup/lab
# event FILE NAME: the counter NAME in FILE is above 0.
event() { awk -v n="$2" '$1 == n && $2 > 0 { f = 1 } END { exit !f }' "$G/$1"; }

task 1 "pam_limits: limited has nofile 100 soft, 200 hard, nproc 50 hard"
need "a file in /etc/security/limits.d sets them" 'grep -hEv "^[[:space:]]*#" /etc/security/limits.d/* 2>/dev/null | grep -E "^[[:space:]]*limited[[:space:]]" | grep -q nofile'
need "a login shell as limited has nofile soft 100" '[ "$(as_user limited "ulimit -Sn")" = 100 ]'
need "a login shell as limited has nofile hard 200" '[ "$(as_user limited "ulimit -Hn")" = 200 ]'
need "a login shell as limited has nproc hard 50" '[ "$(as_user limited "ulimit -Hu")" = 50 ]'

task 2 "Cgroup lab: 50M, no swap, 5 tasks, and both limits hit"
need "/sys/fs/cgroup/lab exists" '[ -d $G ]'
need "memory.max is 50M" '[ "$(cat $G/memory.max)" = 52428800 ]'
need "memory.swap.max is 0" '[ "$(cat $G/memory.swap.max)" = 0 ]'
need "pids.max is 5" '[ "$(cat $G/pids.max)" = 5 ]'
need "the OOM killer has killed something in it" 'event memory.events oom_kill'
need "a fork in it has been refused" 'event pids.events max'

task 3 "lab.slice with TasksMax=20 and MemoryHigh=100M"
need "systemctl show lab.slice says TasksMax=20" '[ "$(systemctl show lab.slice -P TasksMax)" = 20 ]'
need "systemctl show lab.slice says MemoryHigh=100M" '[ "$(systemctl show lab.slice -P MemoryHigh)" = 104857600 ]'
need "the settings are in drop-in files, so they last" 'grep -rqs "TasksMax=20" /etc/systemd/system.control/lab.slice.d /etc/systemd/system/lab.slice.d && grep -rqsE "MemoryHigh=(100M|104857600)" /etc/systemd/system.control/lab.slice.d /etc/systemd/system/lab.slice.d'
