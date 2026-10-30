LOG=$LAB_STATE/watch.log

task 1 "Group sales (GID 3000) with alice and bob"
need "sales:x:3000 had alice and bob as members" 'grep -Eq "(^| )sales:x:3000:(alice,bob|bob,alice)( |$)" "$LOG"'
need "alice is still in projects" 'id -nG alice | grep -qw projects'
need "bob is still in support" 'id -nG bob | grep -qw support'

task 2 "bob out, group renamed market with GID 3001"
need "getent group market prints market:x:3001:alice" '[ "$(getent group market)" = "market:x:3001:alice" ]'
need "there's no group sales any more" '! getent group sales'
need "alice is still in projects" 'id -nG alice | grep -qw projects'

task 3 "groupdel refused to remove alice's primary group"
need "/root/lab-answers/3 has groupdel's message" 'grep -qi "cannot remove the primary group" /root/lab-answers/3'
need "group alice still exists" 'getent group alice'
