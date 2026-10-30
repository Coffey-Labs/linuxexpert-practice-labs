LOG=$LAB_STATE/watch.log
# A boolean's (current, default) from semanage, as "on,off".
pair() { semanage boolean -l 2>/dev/null | grep -E "^$1[[:space:]]" | sed -E 's/^[^(]*\(([a-z]+)[[:space:]]*,[[:space:]]*([a-z]+)\).*/\1,\2/'; }

task 1 "httpd_can_network_connect on, persistently"
need "getsebool httpd_can_network_connect prints --> on" 'getsebool httpd_can_network_connect | grep -q -- "--> on$"'
need "it's on in the saved policy too: semanage boolean -l shows (on , on)" '[ "$(pair httpd_can_network_connect)" = on,on ]'

task 2 "httpd_enable_homedirs on until a reboot only"
need "httpd_enable_homedirs was on in a boot since the lab started" 'grep -q " on$" "$LOG"'
need "a boot after that started with it off" 'awk "\$2 == \"on\" {onl = NR; onb = \$1} !(\$1 in seen) {seen[\$1] = NR; first[\$1] = \$2} END {for (b in seen) if (b != onb && seen[b] > onl && first[b] == \"off\") exit 0; exit 1}" "$LOG"'
need "getsebool httpd_enable_homedirs prints --> off" 'getsebool httpd_enable_homedirs | grep -q -- "--> off$"'
need "it's off in the saved policy: semanage boolean -l shows (off , off)" '[ "$(pair httpd_enable_homedirs)" = off,off ]'
