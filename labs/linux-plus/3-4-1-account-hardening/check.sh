# field N: hardtest's field N in /etc/shadow.
field() { awk -F: -v n="$1" '$1 == "hardtest" {print $n}' /etc/shadow; }

task 1 "hardtest: aging 90/1/7 and a new password at next login"
need "user hardtest exists" 'id hardtest'
need "maximum 90 days, minimum 1, warning 7" '[ "$(field 5)/$(field 4)/$(field 6)" = 90/1/7 ]'
need "it must change its password at the next login" '[ "$(field 3)" = 0 ]'

task 2 "passwd uses pwquality on Ubuntu" debian
need "libpam-pwquality is installed" 'pkg_installed libpam-pwquality'
need "/etc/pam.d/common-password uses pam_pwquality" 'conf_has /etc/pam.d/common-password pam_pwquality'

task 3 "hardtest locked and expired"
need "its password is locked" 'field 2 | grep -q "^!"'
need "the account has expired" '[ "$(field 8)" = 0 ]'

task 4 "The audit's findings"
need "/root/lab-answers/4 names the other UID 0 account" 'grep -qw toor /root/lab-answers/4'
need "it names the account with an empty password" 'grep -qw guest /root/lab-answers/4'
