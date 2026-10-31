for f in /etc/systemd/system/broken.service /usr/local/bin/missing; do
	[ -e "$f" ] && refuse "$f already exists; the lab needs it absent. Remove it and start the lab again."
done
state_set start "$(date '+%Y-%m-%d %H:%M:%S')"
grep -qs '10\.99\.0\.1' /root/.ssh/known_hosts && state_set had-known-host 1
peer_up
# One error from a program and one from the kernel, for task 3.
logger -t backup -p user.err "backup of /srv failed: no space left on device"
echo '<3>kernel: lab-disk: medium error on sector 4242 (practice lab message)' >/dev/kmsg
true
