H=$(getent passwd alice | cut -d: -f6)
# login_run CMD: run CMD in a new login shell of alice's.
login_run() { sudo -niu alice bash -c "$1" </dev/null 2>/dev/null; }
# inter_run CMD: run CMD in a new interactive shell of alice's.
inter_run() { sudo -niu alice bash -ic "$1" </dev/null 2>/dev/null; }

task 1 "~/bin in alice's PATH, with a script hello that runs by name"
need "$H/bin/hello is an executable file" '[ -f "$H/bin/hello" ] && [ -x "$H/bin/hello" ]'
need "alice's login shell has $H/bin in PATH" 'login_run "echo \$PATH" | tail -n1 | tr : "\n" | grep -Eqx "$H/bin/?|~/bin"'
need "hello runs by name in a new login shell" '[ "$(login_run "command -v hello" | tail -n1)" = "$H/bin/hello" ] && login_run hello | grep -q .'

task 2 "mkcd in alice's ~/.bashrc"
need "mkcd is in $H/.bashrc" 'grep -Eq "mkcd" "$H/.bashrc"'
need "mkcd is a function in a new interactive shell" '[ "$(inter_run "type -t mkcd" | tail -n1)" = function ]'
need "mkcd /tmp/le-mkcd/a/b creates the directory and changes into it" 'rm -rf /tmp/le-mkcd; [ "$(inter_run "mkcd /tmp/le-mkcd/a/b && pwd" | tail -n1)" = /tmp/le-mkcd/a/b ] && [ -d /tmp/le-mkcd/a/b ]; r=$?; rm -rf /tmp/le-mkcd; exit $r'

task 3 "/etc/skel/welcome.txt, copied into newbie's home"
need "/etc/skel/welcome.txt exists" '[ -f /etc/skel/welcome.txt ]'
need "user newbie exists" 'id newbie'
need "newbie's home directory has welcome.txt" '[ -f "$(getent passwd newbie | cut -d: -f6)/welcome.txt" ]'
need "newbie owns that welcome.txt" '[ "$(stat -c %U "$(getent passwd newbie | cut -d: -f6)/welcome.txt")" = newbie ]'
