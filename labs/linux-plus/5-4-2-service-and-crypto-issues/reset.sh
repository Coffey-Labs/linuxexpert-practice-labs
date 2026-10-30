systemctl disable --now --quiet metrics-exporter.service le-lab-tls.service 2>/dev/null
rm -f /etc/systemd/system/metrics-exporter.service /etc/systemd/system/le-lab-tls.service
rm -rf /etc/systemd/system/metrics-exporter.service.d /etc/systemd/system/le-lab-tls.service.d
systemctl daemon-reload
rm -f /usr/local/lib/le-lab/metrics-exporter.py /etc/metrics-exporter.conf
rmdir /usr/local/lib/le-lab 2>/dev/null
rm -rf /etc/le-lab/tls
rmdir /etc/le-lab 2>/dev/null
rm -f /etc/ssh/ssh_config.d/05-legacy-hosts.conf
rm -f /etc/yum.repos.d/internal-tools.repo
true
