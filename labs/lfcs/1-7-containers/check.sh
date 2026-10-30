# The container publishing port 8080, if any.
web=''
for c in $(podman ps -q 2>/dev/null); do
	podman port "$c" 2>/dev/null | grep -Eq '^80/tcp -> .*:8080$' && { web=$c; break; }
done
alice_uid=$(id -u alice 2>/dev/null)
apodman() { runuser -u alice -- env XDG_RUNTIME_DIR=/run/user/$alice_uid podman "$@"; }

task 1 "nginx container on port 8080 serving /srv/web read-only"
need "/srv/web/index.html exists" '[ -s /srv/web/index.html ]'
need "a container publishes port 80 on host port 8080" '[ -n "$web" ]'
need "it's named web (or systemd-web, from Quadlet)" '[[ "$(podman inspect -f "{{.Name}}" "$web")" =~ ^(web|systemd-web)$ ]]'
need "it mounts /srv/web read-only" 'podman inspect -f "{{range .Mounts}}{{println .Source .RW}}{{end}}" "$web" | grep -qx "/srv/web false"'
need "curl localhost:8080 returns /srv/web/index.html" 'curl -s --max-time 5 http://localhost:8080/ | cmp -s - /srv/web/index.html'
need "SELinux is enforcing" '! is_rhel || [ "$(getenforce)" = Enforcing ]'

task 2 "web.service from Quadlet, running and starting at boot"
need "web.service is generated from a Quadlet .container file" 'systemctl show -p SourcePath --value web.service | grep -q "/web\.container$"'
need "web.service starts at boot" 'ls /run/systemd/generator/*.target.wants/web.service'
need "web.service is active" active web.service
need "the page still loads on port 8080" 'curl -s --max-time 5 http://localhost:8080/ | cmp -s - /srv/web/index.html'

task 3 "alice's rootless container with a named volume, started at boot"
need "alice lingers (her services start at boot)" '[ -e /var/lib/systemd/linger/alice ]'
need "alice has a running container" '[ -n "$(apodman ps -q)" ]'
need "it keeps data in a named volume" '
	for c in $(apodman ps -q); do apodman inspect -f "{{range .Mounts}}{{.Type}} {{end}}" "$c"; done | grep -qw volume'
need "something starts it at boot (Quadlet or a restart policy)" '
	ls /home/alice/.config/containers/systemd/*.container ||
	{ ls /home/alice/.config/systemd/user/*.target.wants/podman-restart.service &&
	  for c in $(apodman ps -q); do apodman inspect -f "{{.HostConfig.RestartPolicy.Name}}" "$c"; done | grep -qE "always|unless-stopped"; }'

task 4 "Image site:1.0 built and run with an extra variable"
need "podman images lists localhost/site:1.0" 'podman image exists localhost/site:1.0'
need "a container runs (or ran) from site:1.0" '[ -n "$(podman ps -a -q --filter ancestor=localhost/site:1.0)" ]'
need "it has a variable the image doesn't set" '
	img=$(podman image inspect -f "{{range .Config.Env}}{{println .}}{{end}}" localhost/site:1.0)
	for c in $(podman ps -a -q --filter ancestor=localhost/site:1.0); do
		podman inspect -f "{{range .Config.Env}}{{println .}}{{end}}" "$c"
	done | grep . | grep -vxF -f <(printf "%s\n" "$img") | grep -vE "^(container|HOSTNAME|TERM|HOME)=" | grep -q .'

task 5 "Docker installed, logging to journald"
need "docker is installed" 'command -v docker'
need "the Docker daemon is running" active docker
need "docker info shows the journald log driver" '[ "$(docker info --format "{{.LoggingDriver}}" 2>/dev/null)" = journald ]'
