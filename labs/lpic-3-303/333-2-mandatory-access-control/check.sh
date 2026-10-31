code() { curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$1"; }
fcrule() { semanage fcontext -l -C 2>/dev/null | grep -F '/srv/web(/.*)?' | grep -q httpd_sys_content_t; }

task 1 "Apache serves /srv/web on 8089, SELinux enforcing, narrow fixes"
need "SELinux is enforcing" '[ "$(getenforce)" = Enforcing ]'
need "httpd is running and enabled" 'active httpd && enabled httpd'
need "port 8089 is labeled http_port_t" 'semanage port -l | grep -E "^http_port_t[[:space:]]" | grep -qw 8089'
need "a local file-context rule labels /srv/web(/.*)? httpd_sys_content_t" fcrule
need "/srv/web/index.html has that label" 'ls -Z /srv/web/index.html | grep -q httpd_sys_content_t'
need "http://127.0.0.1:8089/ says hello from /srv/web" 'for i in $(seq 10); do curl -s --max-time 5 http://127.0.0.1:8089/ | grep -q "hello from /srv/web" && exit 0; sleep 1; done; exit 1'
need "the nis_enabled boolean is still off" 'getsebool nis_enabled | grep -q "off$"'

task 2 "moved.html, relabeled, is served"
need "/srv/web/moved.html is labeled httpd_sys_content_t" 'ls -Z /srv/web/moved.html | grep -q httpd_sys_content_t'
need "http://127.0.0.1:8089/moved.html says moved page" 'curl -s --max-time 5 http://127.0.0.1:8089/moved.html | grep -q "moved page"'
need "httpd_enable_homedirs is still off" 'getsebool httpd_enable_homedirs | grep -q "off$"'

task 3 "CGI script runs in httpd_sys_script_t"
need "http://127.0.0.1/cgi-bin/lab.sh runs in httpd_sys_script_t" 'curl -s --max-time 5 http://127.0.0.1/cgi-bin/lab.sh | grep "CGI running as" | grep -q httpd_sys_script_t'
need "httpd_enable_cgi is on, now and at boot" 'getsebool httpd_enable_cgi | grep -q "on$" && semanage boolean -l | grep -E "^httpd_enable_cgi " | grep -q "(on *, *on)"'

task 4 "labweb built from the permissive denials, then removed"
need "/srv/web/secret.txt has the type admin_home_t" 'ls -Z /srv/web/secret.txt | grep -q admin_home_t'
need "/root/selinux/labweb.te allows httpd_t to read admin_home_t files" 'grep -q "allow httpd_t admin_home_t:file" /root/selinux/labweb.te && grep -A1 "allow httpd_t admin_home_t:file" /root/selinux/labweb.te | grep -q read'
need "/root/selinux/labweb.pp was built" '[ -s /root/selinux/labweb.pp ]'
need "the labweb module isn't installed now" '! semodule -l | grep -qx labweb'
need "httpd_t isn't permissive now" '! semanage permissive -l | grep -qx "httpd_t"'
need "Apache refuses secret.txt again" '[ "$(code http://127.0.0.1:8089/secret.txt)" = 403 ]'

task 5 "confined is mapped to user_u"
need "semanage login -l maps confined to user_u" 'semanage login -l | awk "\$1 == \"confined\" { print \$2 }" | grep -qx user_u'
