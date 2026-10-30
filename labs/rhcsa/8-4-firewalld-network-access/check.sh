Z=$(state_get zone) LOG=$LAB_STATE/watch.log
fw() { firewall-cmd --zone="$Z" "$@"; }
# The zone's services, sorted, one per line.
svcs() { fw "$@" --list-services | tr ' ' '\n' | sed '/^$/d' | sort; }
want() { { cat "$LAB_STATE/services-before"; printf 'http\nhttps\n'; } | sed '/^$/d' | sort -u; }
# Log lines where the runtime part (R) or the permanent part (P) matches.
rt() { sed -n 's/^R \(.*\) P .*/\1/p' "$LOG" 2>/dev/null; }
pm() { sed -n 's/.* P \(.*\)$/\1/p' "$LOG" 2>/dev/null; }

task 1 "HTTP and HTTPS allowed permanently, nothing else new"
need "firewalld is running and starts at boot" 'active firewalld && enabled firewalld'
need "the permanent services are the ones from before plus http and https" '[ "$(svcs --permanent)" = "$(want)" ]'
need "the runtime services are the same (reloaded)" '[ "$(svcs)" = "$(want)" ]'
need "firewall-cmd --list-ports is empty, now and permanently" '[ -z "$(fw --list-ports)" ] && [ -z "$(fw --permanent --list-ports)" ]'

task 2 "8080/tcp allowed at runtime only, then gone after a reload"
need "8080/tcp was allowed at runtime but not permanently" 'grep -E "^R ports=[^ ]*8080/tcp" "$LOG" | grep -vq " P ports=[^ ]*8080/tcp"'
need "8080/tcp isn't allowed now" '! fw --query-port=8080/tcp && ! fw --permanent --query-port=8080/tcp'

task 3 "ftp saved to permanent with --runtime-to-permanent, then removed"
need "ftp was in the permanent configuration" 'pm | grep -Eq "services=([^ ]*,)?ftp(,|$)"'
need "ftp isn't allowed now, at runtime or permanently" '! fw --query-service=ftp && ! fw --permanent --query-service=ftp'
