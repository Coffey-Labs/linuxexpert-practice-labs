type_of() { stat -c %C "$1" 2>/dev/null | cut -d: -f3; }
rule_for() { matchpathcon -n "$1" 2>/dev/null | cut -d: -f3; }

task 1 "Web pages served from /srv/web, labeled for good"
need "/srv/web/index.html exists" '[ -s /srv/web/index.html ]'
need "/srv/web is labeled httpd_sys_content_t" '[ "$(type_of /srv/web)" = httpd_sys_content_t ]'
need "a file-context rule keeps /srv/web httpd_sys_content_t after restorecon" '[ "$(rule_for /srv/web)" = httpd_sys_content_t ] && [ "$(rule_for /srv/web/index.html)" = httpd_sys_content_t ]'
need "curl localhost returns /srv/web/index.html" 'curl -s --max-time 5 http://localhost/ | cmp -s - /srv/web/index.html'
need "SELinux is enforcing" '[ "$(getenforce)" = Enforcing ]'

task 2 "A moved page in /srv/web fixed and served"
need "/srv/web/moved.html exists" '[ -s /srv/web/moved.html ]'
need "moved.html is labeled httpd_sys_content_t" '[ "$(type_of /srv/web/moved.html)" = httpd_sys_content_t ]'
need "curl localhost/moved.html returns the page" 'curl -s --max-time 5 http://localhost/moved.html | cmp -s - /srv/web/moved.html'

task 3 "sshd listens on 2222 as well as 22"
need "port 2222 is labeled ssh_port_t" 'semanage port -l | awk "\$1 == \"ssh_port_t\" && \$2 == \"tcp\"" | grep -Eq "[ ,]2222(,|$)"'
need "sshd's configuration has ports 22 and 2222" 'sshd -T 2>/dev/null | grep -qx "port 22" && sshd -T 2>/dev/null | grep -qx "port 2222"'
need "sshd answers on port 2222" 'timeout 5 bash -c "exec 3<>/dev/tcp/127.0.0.1/2222; head -c 7 <&3" | grep -q "^SSH-"'
need "sshd still answers on port 22" 'timeout 5 bash -c "exec 3<>/dev/tcp/127.0.0.1/22; head -c 7 <&3" | grep -q "^SSH-"'

task 4 "httpd_can_network_connect on, persistently"
need "httpd_can_network_connect is on" 'getsebool httpd_can_network_connect | grep -q -- "--> on$"'
need "it's saved in the policy, not just for this boot" 'semanage boolean -l -C | grep -Eq "^httpd_can_network_connect[[:space:]]+\(on[[:space:]]*,[[:space:]]*on\)"'

task 5 "Booted permissive once, then enforcing for good"
need "a boot since the lab started ran in permissive mode" 'grep -q " Permissive$" "$LAB_STATE/boot-modes"'
need "/etc/selinux/config sets SELINUX=enforcing" 'grep -Eq "^[[:space:]]*SELINUX=enforcing[[:space:]]*$" /etc/selinux/config'
need "SELinux is enforcing now" '[ "$(getenforce)" = Enforcing ]'
need "the kernel command line doesn't override it" '! grep -Eq "(^| )(enforcing=0|selinux=0)( |$)" /proc/cmdline'
