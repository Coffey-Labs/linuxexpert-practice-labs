D=/root/scans
# xml FILE EXPR: run a Python expression on the root of an nmap XML file;
# p(N) is port N's state, svc(N) its service element.
xml() {
	python3 -c '
import sys, xml.etree.ElementTree as ET
r = ET.parse(sys.argv[1]).getroot()
def port(n):
    for p in r.iter("port"):
        if p.get("protocol") == "tcp" and p.get("portid") == str(n):
            return p
def p(n):
    x = port(n)
    return x.find("state").get("state") if x is not None else None
def svc(n):
    x = port(n)
    return x.find("service") if x is not None else None
sys.exit(0 if eval(sys.argv[2]) else 1)
' "$1" "$2" 2>/dev/null
}
target() { grep -q 'addr="10\.99\.0\.1"' "$1"; }
# rc PORT: curl's exit code from the peer (28 is a timeout, 7 refused).
rc() { in_peer curl -s -o /dev/null --max-time 3 "http://10.99.0.1:$1/"; echo $?; }
nginx_version() { nginx -v 2>&1 | sed 's|.*/||; s| .*||'; }

task 1 "A baseline SYN scan in /root/scans/before.*"
need "nmap is installed" 'command -v nmap'
need "before.nmap, before.gnmap and before.xml exist" '[ -s $D/before.nmap ] && [ -s $D/before.gnmap ] && [ -s $D/before.xml ]'
need "before.xml is a SYN scan of 10.99.0.1" 'target $D/before.xml && grep -q "<scaninfo type=\"syn\"" $D/before.xml'
need "it shows 22, 80, 8080 and 8081 open" 'xml $D/before.xml "all(p(n) == \"open\" for n in (22, 80, 8080, 8081))"'

task 2 "Services and the OS in services.xml, and nginx's version"
need "services.xml is a scan of 10.99.0.1" 'target $D/services.xml'
need "it found nginx on port 80, with a version" 'xml $D/services.xml "svc(80) is not None and \"nginx\" in (svc(80).get(\"product\") or \"\") and svc(80).get(\"version\")"'
need "it tried to detect the operating system" 'xml $D/services.xml "r.find(\"host\").find(\"os\") is not None"'
need "/root/lab-answers/2 has nginx's version" '[ -n "$(answer 2)" ] && [ "$(answer 2)" = "$(nginx_version)" ]'

task 3 "Table inet scanlab: 8080 dropped, 8081 reset, for the peer"
need "the table inet scanlab exists" 'nft list table inet scanlab'
need "port 80 still answers the peer" '[ "$(rc 80)" = 0 ]'
need "port 8080 times out for the peer" '[ "$(rc 8080)" = 28 ]'
need "port 8081 refuses the peer" '[ "$(rc 8081)" = 7 ]'
need "this VM itself still reaches 8080" 'curl -s -o /dev/null --max-time 3 http://10.99.0.1:8080/'

task 4 "The scan after the change, and the ACK scan's finding"
need "after.nmap, after.gnmap and after.xml exist" '[ -s $D/after.nmap ] && [ -s $D/after.gnmap ] && [ -s $D/after.xml ]'
need "after.xml is a SYN scan of 10.99.0.1" 'target $D/after.xml && grep -q "<scaninfo type=\"syn\"" $D/after.xml'
need "it shows 80 open, 8080 filtered and 8081 closed" 'xml $D/after.xml "p(80) == \"open\" and p(8080) == \"filtered\" and p(8081) == \"closed\""'
need "/root/lab-answers/4 has the port the ACK scan calls filtered" '[ "$(answer 4)" = 8080 ]'

task 5 "ndiff's comparison in diff.txt" debian
need "diff.txt shows 8080 and 8081 no longer open" 'grep -Eq "^-8080/tcp +open" $D/diff.txt && grep -Eq "^-8081/tcp +open" $D/diff.txt'
need "and 22 and 80 unchanged" '! grep -Eq "^[-+](22|80)/tcp" $D/diff.txt'

task 6 "ssh2-enum-algos, and the vuln scripts"
need "ssh-algos.txt has the server's key exchange algorithms" 'grep -q "kex_algorithms" $D/ssh-algos.txt && grep -q "$(sshd -T | awk "/^kexalgorithms/ { split(\$2, a, \",\"); print a[1] }")" $D/ssh-algos.txt'
need "/root/lab-answers/6 has the number of vuln scripts" '[ "$(answer 6)" = "$(grep -c "\"vuln\"" /usr/share/nmap/scripts/script.db)" ]'
