user_add alice
user_add student
state_set home "$(getent passwd student | cut -d: -f6)"
saved=$LAB_STATE/saved
mkdir -p "$saved"
cp -a /etc/profile /etc/bash.bashrc /etc/security/limits.conf "$saved/"
ls /etc/profile.d >"$LAB_STATE/profile-d"
ls /etc/security/limits.d >"$LAB_STATE/limits-d"
true
