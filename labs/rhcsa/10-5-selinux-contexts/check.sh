type_of() { stat -c %C "$1" 2>/dev/null | cut -d: -f3; }
rule_for() { matchpathcon -n "$1" 2>/dev/null | cut -d: -f3; }

task 1 "Web content served from /web, labeled for good"
need "SELinux is enforcing" '[ "$(getenforce)" = Enforcing ]'
need "a file in /etc/httpd/conf.d sets DocumentRoot /web" 'grep -Eqs "^[[:space:]]*DocumentRoot[[:space:]]+\"?/web/?\"?[[:space:]]*$" /etc/httpd/conf.d/*.conf'
need "httpd is running" active httpd
need "a file-context rule labels /web httpd_sys_content_t" '[ "$(rule_for /web)" = httpd_sys_content_t ] && [ "$(rule_for /web/index.html)" = httpd_sys_content_t ]'
need "restorecon -Rvn /web lists nothing to change" '[ -z "$(restorecon -Rvn /web 2>&1)" ]'
need "curl http://localhost/ shows /web/index.html" 'curl -s --max-time 5 http://localhost/ | cmp -s - /web/index.html'

task 2 "A file moved from /tmp into /var/www/html, fixed"
need "/var/www/html/page.html exists" test -f /var/www/html/page.html
need "/root/lab-answers/2 has the type after the move (user_tmp_t)" '[ "$(answer 2)" = user_tmp_t ]'
need "page.html is labeled httpd_sys_content_t now" '[ "$(type_of /var/www/html/page.html)" = httpd_sys_content_t ]'

task 3 "chcon undone by restorecon"
need "/root/lab-answers/3 has the type restorecon put back" '[ "$(answer 3)" = httpd_sys_content_t ]'
need "label.html is labeled httpd_sys_content_t again" '[ "$(type_of /var/www/html/label.html)" = httpd_sys_content_t ]'
