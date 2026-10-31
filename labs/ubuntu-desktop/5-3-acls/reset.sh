rm -rf /srv/shared /tmp/new
# The users go after this script; take bob out of the group first.
gpasswd -d bob designers >/dev/null 2>&1
groupdel designers 2>/dev/null
if [ -n "$(state_get added-acl)" ]; then
	DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge acl >/dev/null 2>&1
fi
true
