for s in nginx httpd apache2; do
	systemctl disable --quiet --now "$s" 2>/dev/null
done
systemctl unmask --quiet cups.service 2>/dev/null
systemctl disable --quiet --now cups.service cups.socket cups.path 2>/dev/null
t=$(state_get default-target)
[ -n "$t" ] && systemctl set-default --quiet "$t"
pkill -u alice sleep 2>/dev/null
true
