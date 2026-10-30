# Quadlet and the containers.
systemctl stop web.service 2>/dev/null
rm -f /etc/containers/systemd/web.container
systemctl daemon-reload
podman rm -f -t 0 web systemd-web >/dev/null 2>&1
for c in $(podman ps -a -q --filter ancestor=localhost/site:1.0 2>/dev/null); do podman rm -f -t 0 "$c" >/dev/null 2>&1; done
podman rmi -f localhost/site:1.0 >/dev/null 2>&1
rm -rf /srv/web
# alice's containers go with her account; stop her services first.
if id alice >/dev/null 2>&1; then
	loginctl disable-linger alice 2>/dev/null
	loginctl terminate-user alice 2>/dev/null
	systemctl stop "user@$(id -u alice).service" 2>/dev/null
fi
# Docker back to its default log driver.
if [ -f /etc/docker/daemon.json ]; then
	python3 - <<'X'
import json, os
p = "/etc/docker/daemon.json"
try:
    d = json.load(open(p))
except Exception:
    d = None
if isinstance(d, dict):
    d.pop("log-driver", None)
    if d:
        json.dump(d, open(p, "w"), indent=2)
    else:
        os.remove(p)
X
	systemctl is-active --quiet docker && systemctl restart docker
fi
true
