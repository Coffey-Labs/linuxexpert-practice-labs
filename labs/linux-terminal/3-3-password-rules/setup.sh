id dave >/dev/null 2>&1 && refuse "user dave already exists; task 3 creates him. Remove him (userdel -r dave) and start the lab again."
user_add alice
user_add pwtest
saved=$LAB_STATE/saved
mkdir -p "$saved"
cp -a /etc/pam.d/common-password /etc/login.defs "$saved/"
[ -f /etc/security/pwquality.conf ] && cp -a /etc/security/pwquality.conf "$saved/"
[ -d /etc/security/pwquality.conf.d ] && cp -a /etc/security/pwquality.conf.d "$saved/"
dpkg-query -W -f '${Package}\n' >"$LAB_STATE/packages"
# Aging of the existing accounts, for task 3.
for u in root pwtest; do getent shadow $u | cut -d: -f5 >"$LAB_STATE/max-$u"; done
true
