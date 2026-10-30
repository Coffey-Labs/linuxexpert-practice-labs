target='^lab-(alma|ubuntu)\.example\.test$'

task 1 "Hostname lab-alma.example.test"
need "the static hostname is lab-alma.example.test" 'hostnamectl --static | grep -Eq "$target"'
need "hostname prints it too" 'hostname | grep -Eq "$target"'

task 2 "Time zone UTC"
need "timedatectl shows the time zone UTC" 'case $(timedatectl show -p Timezone --value) in UTC | Etc/UTC) true ;; *) false ;; esac'

task 3 "vm.swappiness 20, now and after a reboot"
need "vm.swappiness is 20 now" '[ "$(sysctl -n vm.swappiness)" = 20 ]'
need "a file in /etc/sysctl.d sets it to 20" 'grep -Eqs "^[[:space:]]*vm[./]swappiness[[:space:]]*=[[:space:]]*20[[:space:]]*$" /etc/sysctl.d/*.conf'
