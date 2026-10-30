ldap_attr() {
	ldapsearch -x -LLL -o ldif-wrap=no -o nettimeout=10 -H ldap://ldap.example.org \
		-b dc=example,dc=org "$1" "$2" 2>/dev/null | sed -n "s/^$2: //Ip"
}
# Members of developers, as memberUid or as member DNs.
dev_members() {
	ldap_attr '(&(objectClass=posixGroup)(cn=developers))' memberUid
	ldap_attr '(cn=developers)' member | sed -n 's/^uid=\([^,]*\),.*/\1/Ip'
}
# A real login with a password: su - USER from an ordinary user, on a
# terminal. Prints the last line of the output.
PTY_LOGIN='
import os, pty, select, sys, time
user, pw, cmd = sys.argv[1:4]
pid, fd = pty.fork()
if pid == 0:
    os.environ["LC_ALL"] = "C"
    os.execvp("su", ["su", "-", user, "-c", cmd])
out, sent, end = b"", False, time.time() + 30
while time.time() < end:
    if not select.select([fd], [], [], 1)[0]:
        continue
    try:
        data = os.read(fd, 1024)
    except OSError:
        break
    if not data:
        break
    out += data
    if not sent and b"assword" in out:
        os.write(fd, pw.encode() + b"\n")
        sent = True
os.waitpid(pid, 0)
sys.stdout.write(out.decode(errors="replace"))
'
pty_login() { (cd / && runuser -u nobody -- python3 -c "$PTY_LOGIN" "$@" 2>/dev/null | tr -d '\r' | tail -n1); }

task 1 "A directory at ldap.example.org with alice, bob and developers"
need "ldap://ldap.example.org answers for dc=example,dc=org" 'ldapsearch -x -o nettimeout=10 -H ldap://ldap.example.org -b dc=example,dc=org -s base'
need "alice is a posixAccount with UID 10001" '[ "$(ldap_attr "(&(objectClass=posixAccount)(uid=alice))" uidNumber)" = 10001 ]'
need "bob is a posixAccount with UID 10002" '[ "$(ldap_attr "(&(objectClass=posixAccount)(uid=bob))" uidNumber)" = 10002 ]'
need "developers is a posixGroup with GID 10100" '[ "$(ldap_attr "(&(objectClass=posixGroup)(cn=developers))" gidNumber)" = 10100 ]'
need "developers contains alice and bob" 'dev_members | grep -qx alice && dev_members | grep -qx bob'

task 2 "SSSD: the users resolve, log in and get a home directory"
need "getent passwd alice shows UID 10001, through SSSD" '[ "$(getent -s sss passwd alice | cut -d: -f3)" = 10001 ]'
need "getent passwd bob shows UID 10002, through SSSD" '[ "$(getent -s sss passwd bob | cut -d: -f3)" = 10002 ]'
need "id alice lists group developers" 'id -nG alice | grep -qw developers'
need "alice logs in with password Lab-Pass-1 and lands in /home/alice" '[ "$(pty_login alice Lab-Pass-1 pwd)" = /home/alice ]'
need "/home/alice belongs to alice" '[ "$(stat -c %u /home/alice)" = 10001 ]'

task 3 "bob's shell changed to /bin/sh in the directory, seen at once"
need "bob's loginShell in the directory is /bin/sh" '[ "$(ldap_attr "(uid=bob)" loginShell)" = /bin/sh ]'
need "getent passwd bob shows /bin/sh" '[ "$(getent -s sss passwd bob | cut -d: -f7)" = /bin/sh ]'

task 4 "SSSD's start failure found in the logs and fixed"
need "/root/lab-answers/4 has the log message about sssd.conf's permissions" 'grep -qi permission /root/lab-answers/4'
need "sssd.conf belongs to root and isn't readable by others" '[ "$(stat -c %U /etc/sssd/sssd.conf)" = root ] && [ $((0$(stat -c %a /etc/sssd/sssd.conf) & 7)) = 0 ]'
need "sssd is running" active sssd
need "sssd starts at boot" enabled sssd
