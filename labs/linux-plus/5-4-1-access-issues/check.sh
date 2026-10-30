F=/srv/lab/inner/f.txt
as() { runuser -u permtest -- "$@"; }
field() { awk -F: -v n="$1" '$1 == "permtest" {print $n}' /etc/shadow; }

task 1 "permtest can read f.txt; the blocking directory found"
need "/root/lab-answers/1 names the directory" '[ "$(answer 1 | sed "s|/*$||")" = /srv/lab ]'
need "permtest can read $F" 'as cat '$F' | grep -qx data'
need "others can't write to /srv/lab" '[ $(( 0$(stat -c %a /srv/lab) & 2 )) = 0 ]'

task 2 "permtest can write to f.txt; the limiting entry found"
need "/root/lab-answers/2 names the entry" 'answer 2 | grep -qw mask'
need "permtest still has its rw ACL entry" 'getfacl -p '$F' 2>/dev/null | grep -q "^user:permtest:rw"'
need "permtest can write to $F" 'as test -w '$F
need "others can't write to it" '[ "$(stat -c %A '$F' | cut -c9)" = - ]'

task 3 "old-report.txt deleted; the attribute found"
need "/root/lab-answers/3 names the attribute" 'answer 3 | grep -Eqw "immutable|i"'
need "/srv/lab/inner/old-report.txt is gone" '[ ! -e /srv/lab/inner/old-report.txt ]'

task 4 "permtest can log in again"
need "permtest's shell is bash" '[ "$(getent passwd permtest | cut -d: -f7)" = /bin/bash ] || [ "$(getent passwd permtest | cut -d: -f7)" = /usr/bin/bash ]'
need "its account never expires" '[ -z "$(field 8)" ] || [ "$(field 8)" = -1 ]'
need "su - permtest runs a command" 'su - permtest -c "echo le-ok" </dev/null | grep -q le-ok'
