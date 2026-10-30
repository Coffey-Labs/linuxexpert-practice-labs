T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
mkdir "$T/somedir"
echo data >"$T/somefile"
# cf ARGS: run checkfiles.sh in $T; output in $T/out, lowercase; exit status.
cf() { (cd "$T" && /root/checkfiles.sh "$@" >"$T/out.raw" 2>&1); local r=$?; tr A-Z a-z <"$T/out.raw" >"$T/out"; return $r; }
line_for() { grep -E "(^|[^a-z0-9_.-])$1([^a-z0-9_.-]|$)" "$T/out"; }
# svc ARG: service.sh's output, lowercase.
svc() { timeout 10 /root/service.sh "$@" 2>&1 </dev/null | tr A-Z a-z; }

task 1 "checkfiles.sh reports missing files, directories and readable files"
need "/root/checkfiles.sh is executable" '[ -x /root/checkfiles.sh ]'
need "with all files present it exits 0" 'cf somefile somedir'
need "it reports somedir as a directory" 'cf somefile somedir; line_for somedir | grep -q director'
need "it reports somefile as readable" 'cf somefile somedir; line_for somefile | grep -q readable'
need "with a missing file it exits 1" 'cf somefile nosuchfile somedir; [ $? = 1 ]'
need "it reports nosuchfile as missing" 'cf somefile nosuchfile somedir; line_for nosuchfile | grep -q missing'
need "it reports every file it's given" 'cf nosuchfile somefile somedir; [ "$(grep -cE "somefile|somedir|nosuchfile" "$T/out")" -ge 3 ]'

task 2 "A diskcheck report in root's mail"
need "a mail command is installed" 'command -v mail'
need "an MTA is running" 'active postfix || listening 25 tcp'
need "root has a message from diskcheck" 'grep -qs "^Subject: Disk space on" /var/mail/root /var/spool/mail/root /root/mbox'

task 3 "count.sh prints 1 to 10 with a while loop"
need "/root/count.sh is executable" '[ -x /root/count.sh ]'
need "it prints 1 to 10, one per line" '[ "$(timeout 10 /root/count.sh </dev/null)" = "$(seq 1 10)" ]'
need "it uses while" 'grep -Eq "(^|[;[:space:]])while[[:space:]]" /root/count.sh'
need "it has no for loop" '! grep -Ev "^[[:space:]]*#" /root/count.sh | grep -Eq "(^|[;[:space:]])for[[:space:]]"'

task 4 "service.sh: start, stop, status, and usage for anything else"
need "/root/service.sh is executable" '[ -x /root/service.sh ]'
need "it uses case" 'grep -Eq "(^|[[:space:]])case[[:space:]]" /root/service.sh'
need "start, stop and status each print something, not the usage" 'for a in start stop status; do o=$(svc $a); [ -n "$o" ] && ! grep -q usage <<<"$o" || exit 1; done'
need "anything else prints a usage message" 'svc restart | grep -q usage && svc bogus | grep -q usage'
need "no argument prints a usage message" 'svc | grep -q usage'
