pkg_install sysstat strace
mkdir -p /var/lib/lab-report /usr/local/lib/le-lab
printf 'level=2\nformat=text\n' >/var/lib/lab-report/rules.conf
cat >/usr/local/bin/lab-report <<'X'
#!/bin/bash
# Writes a short report; its settings come from its rules file.
n=0
while read -r line; do n=$((n + 1)); done </var/lib/lab-report/rules.conf
echo "report done ($n rules)"
X
chmod 755 /usr/local/bin/lab-report
# A busy process under a name of its own.
cp /usr/bin/yes /usr/local/lib/le-lab/indexer
systemd-run --quiet --unit=le-lab-stopped /usr/bin/sleep 3000
systemd-run --quiet --unit=le-lab-zombie /bin/bash -c 'sleep 1 & exec sleep 3000'
systemd-run --quiet --unit=le-lab-busy -p StandardOutput=null /usr/local/lib/le-lab/indexer
sleep 1
kill -STOP "$(systemctl show -p MainPID --value le-lab-stopped.service)"
