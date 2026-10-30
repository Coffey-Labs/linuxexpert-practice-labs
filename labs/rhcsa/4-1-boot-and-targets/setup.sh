# Emergency mode needs root's password; without one the student is stuck.
case $(passwd -S root 2>/dev/null | awk '{print $2}') in
L* | NP)
	refuse "root has no usable password, and this lab's next boot stops in emergency mode, which asks for it. Run: sudo passwd root, then start the lab again."
	;;
esac
[ -f /run/systemd/shutdown/scheduled ] && refuse "a shutdown is scheduled already; cancel it with shutdown -c and start the lab again."
# A marker in /var/log/messages: task 3 looks for a cancel after it.
token=le-lab-$(date +%s)-$RANDOM
state_set token "$token"
state_set since "$(date +%s)"
# Written straight into the file: through logger it can arrive late.
printf '%s %s le-lab: lab started %s\n' "$(date '+%b %e %T')" "$(hostname -s)" "$token" >>/var/log/messages
mkdir -p /mnt/nodisk
printf 'LABEL=le-nodisk /mnt/nodisk xfs defaults 0 0\n' >>/etc/fstab
systemctl daemon-reload
