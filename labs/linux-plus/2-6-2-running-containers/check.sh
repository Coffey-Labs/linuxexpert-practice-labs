auid=$(id -u alice 2>/dev/null)
apodman() { (cd / && runuser -u alice -- env XDG_RUNTIME_DIR=/run/user/$auid podman "$@"); }
aanswer() { head -n1 "/home/alice/answers/$1" 2>/dev/null | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'; }
# NAME= from an nginx image of alice's.
os_name() {
	local img
	img=$(apodman inspect -f '{{.ImageName}}' web 2>/dev/null) ||
		img=$(apodman images --format '{{.Repository}}:{{.Tag}}' | grep -m1 nginx)
	apodman run --rm --entrypoint sh "$img" -c '. /etc/os-release; echo "$NAME"'
}
subuid_start() { awk -F: -v u=alice '$1 == u {print $2; exit}' /etc/subuid; }
web_up() { for i in $(seq 10); do [ "$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 http://127.0.0.1:8080/)" = 200 ] && return 0; sleep 1; done; return 1; }

task 1 "web runs nginx:1.30 on port 8080 with TZ=UTC"
need "alice has a running container named web" '[ "$(apodman inspect -f "{{.State.Status}}" web)" = running ]'
need "it runs nginx 1.30" 'apodman inspect -f "{{.ImageName}}" web | grep -q "nginx:1.30"'
need "it publishes port 80 on host port 8080" 'apodman port web | grep -Eq "^80/tcp -> .*:8080$"'
need "it has TZ=UTC" 'apodman inspect -f "{{range .Config.Env}}{{println .}}{{end}}" web | grep -qx TZ=UTC'
need "http://127.0.0.1:8080 answers 200" web_up

task 2 "The container's OS name"
need "~/answers/2 has the NAME from the container's /etc/os-release" 'a=$(aanswer 2); [ -n "$a" ] && [ "${a,,}" = "$(os_name | tr A-Z a-z)" ]'

task 3 "Where UID 1 maps on the host"
need "~/answers/3 has the start of alice's subordinate UID range" '[ -n "$(subuid_start)" ] && [ "$(aanswer 3)" = "$(subuid_start)" ]'
