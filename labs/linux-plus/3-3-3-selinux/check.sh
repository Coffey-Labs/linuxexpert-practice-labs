F=/var/www/html/moved.html
type_of() { stat -c %C "$1" 2>/dev/null | cut -d: -f3; }

task 1 "httpd installed, enabled and running"
need "httpd is running" active httpd
need "httpd is enabled" enabled httpd

task 2 "The moved page labeled right and served"
need "$F exists and says moved" 'grep -qx moved '$F
need "it's labeled httpd_sys_content_t" '[ "$(type_of '$F')" = httpd_sys_content_t ]'
need "curl http://127.0.0.1/moved.html returns it" 'curl -s --max-time 5 http://127.0.0.1/moved.html | grep -qx moved'
need "SELinux is enforcing" '[ "$(getenforce)" = Enforcing ]'

task 3 "The moved file's type before the fix"
need "/root/lab-answers/3 has a home directory type" 'case $(answer 3) in user_home_t | admin_home_t) exit 0 ;; *) exit 1 ;; esac'

task 4 "httpd_enable_homedirs on, persistently"
need "httpd_enable_homedirs is on" 'getsebool httpd_enable_homedirs | grep -q -- "--> on$"'
need "it's saved in the policy, not just for this boot" 'grep -qx "httpd_enable_homedirs=1" /var/lib/selinux/targeted/active/booleans.local'
