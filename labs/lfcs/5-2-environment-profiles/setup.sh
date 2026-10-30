user_add erin -s /bin/bash
user_add frank -s /bin/bash
mkdir -p /opt/tools/bin
printf '#!/bin/sh\necho "lab tools are on your PATH"\n' >/opt/tools/bin/labtool
chmod 755 /opt/tools/bin/labtool

# Keep what the tasks change, so that reset can put it back.
saved=$LAB_STATE/saved
for f in /etc/skel /etc/profile.d /etc/profile /etc/environment /etc/bashrc \
	/etc/bash.bashrc /etc/security/pam_env.conf /root/.bashrc /root/.bash_profile /root/.profile; do
	if [ -e "$f" ]; then
		mkdir -p "$saved${f%/*}"
		cp -a "$f" "$saved$f"
	else
		printf '%s\n' "$f" >>"$LAB_STATE/absent"
	fi
done
state_set profile-sum "$(sha256sum </etc/profile)"

# A key for check.sh to log in over ssh as erin and frank.
ssh-keygen -q -t ed25519 -N '' -C le-lab -f "$LAB_STATE/ssh-key"
for u in erin frank; do
	install -d -m 700 -o "$u" -g "$u" "/home/$u/.ssh"
	install -m 600 -o "$u" -g "$u" "$LAB_STATE/ssh-key.pub" "/home/$u/.ssh/authorized_keys"
done
if command -v restorecon >/dev/null; then restorecon -R /home/erin/.ssh /home/frank/.ssh; fi
