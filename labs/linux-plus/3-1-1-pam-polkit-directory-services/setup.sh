user_add pat
[ ! -e /etc/nologin ] || refuse "/etc/nologin exists, so only root can log in; remove it and start again"
# pat logs in with a password, so sshd must allow them.
mkdir -p /run/sshd
sshd -T 2>/dev/null | grep -qx 'passwordauthentication yes' ||
	refuse "sshd doesn't allow password logins, which task 2 uses; allow them and start again"
true
