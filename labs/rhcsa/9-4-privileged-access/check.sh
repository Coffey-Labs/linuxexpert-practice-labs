task 1 "Group devs runs anything as root without a password"
need "sudo's configuration is valid" visudo -cq
need "as dan, sudo -n id -u prints 0" '[ "$(runuser -u dan -- sudo -n id -u 2>/dev/null)" = 0 ]'
need "the rule is for group devs, not just dan" 'grep -rqsE "^[[:space:]]*%devs[[:space:]]" /etc/sudoers /etc/sudoers.d'
need "gina (not in devs) can't do the same" '! runuser -u gina -- sudo -n id -u'

task 2 "gina may run only systemctl restart httpd as root"
need "gina may run systemctl restart httpd" 'sudo -n -l -U gina /usr/bin/systemctl restart httpd'
need "gina may not run systemctl stop httpd" '! sudo -n -l -U gina /usr/bin/systemctl stop httpd'
need "gina may not run id" '! sudo -n -l -U gina /usr/bin/id'
need "gina may not run a shell" '! sudo -n -l -U gina /bin/bash'

task 3 "alice has full sudo through wheel, with her password"
need "alice is in group wheel" 'id -nG alice | grep -qw wheel'
need "sudo -l for alice shows (ALL) ALL" 'sudo -n -l -U alice | grep -Eq "^[[:space:]]+\(ALL(: ?ALL)?\) ALL$"'
need "alice can't use sudo without her password" '! runuser -u alice -- sudo -n true'
