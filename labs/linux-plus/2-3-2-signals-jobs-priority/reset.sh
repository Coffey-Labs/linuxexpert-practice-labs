for u in le-lab-sleep1000 le-lab-sleep1001 le-lab-yes; do
	systemctl stop "$u.service" 2>/dev/null
	systemctl reset-failed "$u.service" 2>/dev/null
done
true
