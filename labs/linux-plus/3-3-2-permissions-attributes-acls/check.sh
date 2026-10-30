task 1 "Team directory /srv/team for group labteam"
need "group labteam exists, with pat in it" 'id -nG pat | grep -qw labteam'
need "/srv/team belongs to group labteam" '[ "$(stat -c %G /srv/team)" = labteam ]'
need "/srv/team has mode 3770" '[ "$(stat -c %a /srv/team)" = 3770 ]'
need "/srv/team/mine is pat's, in group labteam" '[ "$(stat -c %U:%G /srv/team/mine)" = pat:labteam ]'

task 2 "/srv/team/locked is immutable"
need "/srv/team/locked exists" '[ -f /srv/team/locked ]'
need "it has the immutable attribute" 'lsattr -d /srv/team/locked | cut -d" " -f1 | grep -q i'

task 3 "acltest reads pat's acl.txt through an ACL"
F=/home/pat/acl.txt
need "$F is pat's and says secret" '[ "$(stat -c %U $F)" = pat ] && grep -qx secret $F'
need "user acltest exists" 'id acltest'
need "its owner has rw, and others have no access" '[ "$(stat -c %A $F | cut -c2,3,8-10)" = "rw---" ]'
need "getfacl shows user:acltest:r--" 'getfacl -p $F 2>/dev/null | grep -qx "user:acltest:r--"'
need "acltest can read it" 'runuser -u acltest -- cat $F | grep -qx secret'
need "another user can't" '! runuser -u nobody -- cat $F'
