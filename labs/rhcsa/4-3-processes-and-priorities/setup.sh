pgrep -x sha256sum >/dev/null && refuse "sha256sum is already running; end it (pkill sha256sum) and start the lab again."
rm -f /root/topmem.txt
for i in 1 2; do
	setsid -f sha256sum /dev/zero >/dev/null 2>&1 </dev/null
done
sleep 1
pgrep -x sha256sum >"$LAB_STATE/pids"
[ "$(wc -l <"$LAB_STATE/pids")" = 2 ] || die "couldn't start the lab's sha256sum processes"
