auid=$(id -u alice 2>/dev/null)
apodman() { (cd / && runuser -u alice -- env XDG_RUNTIME_DIR=/run/user/$auid podman "$@"); }
site_up() {
	for i in $(seq 10); do curl -s --max-time 3 http://127.0.0.1:8080/ | cmp -s - /home/alice/site/index.html && return 0; sleep 1; done
	return 1
}
vol_file() { cat "$(apodman volume inspect -f '{{.Mountpoint}}' labdata)/first.txt"; }
alpine_img() { apodman images --format '{{.Repository}}:{{.Tag}}' | grep -m1 '/alpine:'; }

task 1 "site serves ~/site read-only on port 8080"
need "~/site/index.html exists" '[ -s /home/alice/site/index.html ]'
need "alice has a running container named site" '[ "$(apodman inspect -f "{{.State.Status}}" site)" = running ]'
need "it mounts ~/site read-only" 'apodman inspect -f "{{range .Mounts}}{{println .Source .Destination .RW}}{{end}}" site | grep -qx "/home/alice/site /usr/share/nginx/html false"'
need "it publishes port 80 on host port 8080" 'apodman port site | grep -Eq "^80/tcp -> .*:8080$"'
need "SELinux is enforcing" '! is_rhel || [ "$(getenforce)" = Enforcing ]'
need "~/site has a container label" '! is_rhel || ls -Zd /home/alice/site | grep -q container_file_t'
need "http://127.0.0.1:8080 returns ~/site/index.html" site_up

task 2 "Volume labdata holds first.txt"
need "volume labdata exists" 'apodman volume exists labdata'
need "first.txt in it has a date in it" 'vol_file | grep -Eq "[0-9]{2}:[0-9]{2}:[0-9]{2}"'

task 3 "back answers by name on labnet"
need "network labnet exists" 'apodman network exists labnet'
need "labnet has DNS turned on" '[ "$(apodman network inspect -f "{{.DNSEnabled}}" labnet)" = true ]'
need "back is running on labnet" '[ "$(apodman inspect -f "{{.State.Status}}" back)" = running ] && apodman inspect -f "{{range \$k, \$v := .NetworkSettings.Networks}}{{\$k}} {{end}}" back | grep -qw labnet'
need "another container on labnet fetches http://back" '[ -n "$(alpine_img)" ] && apodman run --rm --network labnet "$(alpine_img)" wget -qO- -T 5 http://back | grep -qi nginx'
