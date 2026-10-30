for u in le-lab-stopped le-lab-zombie le-lab-busy; do
	systemctl kill -s KILL "$u.service" 2>/dev/null
	systemctl stop "$u.service" 2>/dev/null
	systemctl reset-failed "$u.service" 2>/dev/null
done
rm -rf /var/lib/lab-report /usr/local/bin/lab-report /usr/local/lib/le-lab/indexer
rmdir /usr/local/lib/le-lab 2>/dev/null
true
