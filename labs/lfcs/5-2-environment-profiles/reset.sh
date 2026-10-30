userdel -r le-newuser 2>/dev/null
userdel -r testuser 2>/dev/null
# Put back what setup kept; remove what wasn't there before.
saved=$LAB_STATE/saved
if [ -d "$saved" ]; then
	for f in /etc/skel /etc/profile.d /etc/profile /etc/environment /etc/bashrc \
		/etc/bash.bashrc /etc/security/pam_env.conf /root/.bashrc /root/.bash_profile /root/.profile; do
		[ -e "$saved$f" ] || continue
		rm -rf "$f"
		cp -a "$saved$f" "$f"
	done
fi
if [ -f "$LAB_STATE/absent" ]; then
	while read -r f; do rm -rf "$f"; done <"$LAB_STATE/absent"
fi
command -v restorecon >/dev/null && restorecon -R /etc/skel /etc/profile.d /etc/profile /etc/environment /root 2>/dev/null
rm -rf /opt/tools
true
