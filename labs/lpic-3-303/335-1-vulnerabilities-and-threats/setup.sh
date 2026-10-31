[ -e /root/threats ] && refuse "/root/threats already exists; move it away and start again"
listening 2323 tcp && refuse "something already listens on port 2323; stop it and start again"
# Reset removes every package installed from here on, by setup or by the
# tasks, and only those.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
pkgs_now >"$LAB_STATE/pkgs-before"
if systemctl is-active --quiet firewalld; then
	tar -C /etc -cf "$LAB_STATE/firewalld.tar" firewalld
elif command -v ufw >/dev/null && ufw status | grep -q 'Status: active'; then
	tar -C /etc -cf "$LAB_STATE/ufw.tar" ufw
fi
peer_up
user_add hashdemo
mkdir -p /root/threats
cat >/root/threats/greet.c <<'X'
#include <stdio.h>
#include <string.h>
int main(int argc, char **argv) {
    char name[16];
    if (argc < 2)
        return 1;
    strcpy(name, argv[1]);          /* no length check */
    printf("Hello, %s\n", name);
    return 0;
}
X
true
