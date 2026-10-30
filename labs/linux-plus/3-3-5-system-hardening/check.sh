# The overall exposure of the SSH service, as systemd-analyze shows it.
score() { systemd-analyze security "$(pick sshd ssh).service" 2>/dev/null | tail -1 | grep -oE '[0-9]+\.[0-9]+' | head -1; }

task 1 "The service on TCP port 2323 stopped and disabled"
need "nothing listens on port 2323" '! listening 2323 tcp'
need "its unit is stopped and disabled" '! active legacy-console.service && ! enabled legacy-console.service'

task 2 "The setuid program no package installed"
need "/root/lab-answers/2 has its path" '[ "$(answer 2)" = /usr/local/bin/sysreport ]'

task 3 "The capability-holding program no package installed"
need "/root/lab-answers/3 has its path" '[ "$(answer 3)" = /usr/sbin/netprobe ]'

task 4 "A noexec, nosuid, nodev tmpfs on /mnt/nx"
need "a tmpfs is mounted on /mnt/nx" '[ "$(findmnt -n -o FSTYPE /mnt/nx)" = tmpfs ]'
need "it has noexec, nosuid and nodev" 'o=$(findmnt -n -o OPTIONS /mnt/nx); for w in noexec nosuid nodev; do grep -qw $w <<<"$o" || exit 1; done'
need "/mnt/nx/id is there and can't run" '[ -f /mnt/nx/id ] && ! /mnt/nx/id'

task 5 "The SSH service's exposure score"
need "/root/lab-answers/5 has the score" 's=$(score); [ -n "$s" ] && grep -qw "$s" /root/lab-answers/5'
