D=/srv/devs F=/srv/devs/le-check-$$
cleanup() { rm -f "$F"; }
trap cleanup EXIT

task 1 "/srv/devs: group devs, writable by members, no deleting others' files"
need "/srv/devs belongs to group devs" '[ "$(stat -c %G $D)" = devs ]'
need "/srv/devs has the setgid bit" '[ -g $D ]'
need "/srv/devs has the sticky bit" '[ -k $D ]'
need "/srv/devs has a default ACL entry group:devs:rw-" 'getfacl -dpc $D 2>/dev/null | grep -Eq "^(default:)?group:devs:rw[x-]$"'
need "a file alice creates there belongs to group devs" 'runuser -u alice -- sh -c "echo a > $F" && [ "$(stat -c %G $F)" = devs ]'
need "bob can append to alice's file" 'runuser -u bob -- sh -c "echo x >> $F" && grep -qx x $F'
need "bob can't delete alice's file" '! runuser -u bob -- rm -f $F 2>/dev/null; [ -e $F ]'

task 2 "Only bob (and root) can read /srv/secret/f.txt"
need "/srv/secret/f.txt exists" test -f /srv/secret/f.txt
need "/srv/secret has mode 700 for its owner, root" '[ "$(stat -c %U /srv/secret)" = root ] && [ "$(stat -c %a /srv/secret | cut -c1)" = 7 ]'
need "bob can read /srv/secret/f.txt" 'runuser -u bob -- cat /srv/secret/f.txt'
need "alice can't read it" '! runuser -u alice -- cat /srv/secret/f.txt'
need "carol can't read it" '! runuser -u carol -- cat /srv/secret/f.txt'
need "nobody else can read it" '! runuser -u nobody -- cat /srv/secret/f.txt'

task 3 "chmod's effect on the ACL mask noted, then bob's access back"
need "/root/lab-answers/3 shows the effective permissions after chmod 700 (---)" '[[ "$(answer 3)" =~ ^(#?effective:)?---$ ]]'
need "bob still has a user ACL entry with r-x on /srv/reports" 'getfacl -pc /srv/reports 2>/dev/null | grep -q "^user:bob:r-x"'
need "the mask allows r-x again" 'getfacl -pc /srv/reports 2>/dev/null | grep -Eq "^mask::r-x"'
need "bob can list /srv/reports" 'runuser -u bob -- ls /srv/reports'
