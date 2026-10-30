user_add dana
systemd-run --quiet --unit=le-lab-dana-sleep --uid=dana --nice=10 sleep 86400
for _ in 1 2 3 4 5; do
	p=$(systemctl show -p MainPID --value le-lab-dana-sleep)
	[ "${p:-0}" -gt 0 ] && break
	sleep 1
done
state_set pid "$p"
