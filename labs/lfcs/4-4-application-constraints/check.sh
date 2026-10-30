nginx_soft_nofile() { awk '/^Max open files/ {print $4}' "/proc/$(pgrep -o -x nginx)/limits"; }
port81_pid() { ss -Htlnp 'sport = :81' | grep -oE 'pid=[0-9]+' | head -n1 | cut -d= -f2; }
cg_file() { cat "/sys/fs/cgroup$(systemctl show -p ControlGroup --value heartbeat)/$1"; }

task 1 "nginx has a limit of 65536 open files"
need "nginx is running" active nginx
need "nginx starts at boot" enabled nginx
need "the nginx master process has 65536 open files" '[ "$(nginx_soft_nofile)" = 65536 ]'
need "the setting is under /etc/systemd/, which package updates leave alone" 'grep -rEqs "^[[:space:]]*(Default)?LimitNOFILE=65536" /etc/systemd/'

task 2 "nginx's files, ports and libraries listed"
need "/root/lab-answers/2 lists nginx's log files" 'grep -q /var/log/nginx/ /root/lab-answers/2'
need "it lists port 80" 'grep -Eq "(^|[^0-9])80([^0-9]|$)|:http([^a-z]|$)" /root/lab-answers/2'
need "it lists libssl or libcrypto" 'grep -Eq "lib(ssl|crypto)" /root/lab-answers/2'

task 3 "heartbeat.service capped at 200 MiB and 20% CPU"
need "heartbeat.service is running" active heartbeat.service
need "its MemoryMax is 200M" '[ "$(systemctl show -p MemoryMax --value heartbeat)" = 209715200 ]'
need "its CPU quota is 20%" '[ "$(systemctl show -p CPUQuotaPerSecUSec --value heartbeat)" = 200ms ]'
need "both limits are in force in its cgroup" '[ "$(cg_file memory.max)" = 209715200 ] && [ "$(cg_file cpu.max)" = "20000 100000" ]'

task 4 "alice has a hard limit of 200 processes"
need "ulimit -Hu prints 200 in a new login shell of alice" '[ "$(runuser -l alice -s /bin/bash -c "ulimit -Hu" 2>/dev/null)" = 200 ]'

task 5 "webapp runs as webapp, on port 81"
need "something listens on port 81" 'listening 81'
need "the program on port 81 runs as user webapp" '[ "$(ps -o uid= -p "$(port81_pid)" | tr -d " ")" = "$(id -u webapp)" ]'
need "webapp.service is running and starts at boot" 'active webapp.service && enabled webapp.service'
