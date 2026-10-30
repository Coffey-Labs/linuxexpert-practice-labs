auid=$(id -u alice 2>/dev/null)
apodman() { (cd / && runuser -u alice -- env XDG_RUNTIME_DIR=/run/user/$auid podman "$@"); }
http_ok() { for i in $(seq 10); do [ "$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$1")" = 200 ] && return 0; sleep 1; done; return 1; }
svc_running() {
	apodman ps --filter label=com.docker.compose.project=stack --filter "label=com.docker.compose.service=$1" --format '{{.Image}}'
}

task 1 "Compose stack web + cache running from ~/stack"
need "podman-compose is installed" 'command -v podman-compose'
need "~/stack/compose.yaml has services web and cache" 'grep -Eq "^[[:space:]]+web:" /home/alice/stack/compose.yaml && grep -Eq "^[[:space:]]+cache:" /home/alice/stack/compose.yaml'
need "the web service runs nginx" 'svc_running web | grep -q nginx'
need "the cache service runs redis" 'svc_running cache | grep -q redis'
need "http://127.0.0.1:8080 answers 200" 'http_ok http://127.0.0.1:8080/'

task 2 "Pod lab played from ~/stack/lab.yaml"
need "~/stack/lab.yaml is Kubernetes YAML for a pod with nginx" 'grep -q "^kind: Pod" /home/alice/stack/lab.yaml && grep -q "image: .*nginx" /home/alice/stack/lab.yaml'
need "it publishes port 8081" 'grep -q "hostPort: 8081" /home/alice/stack/lab.yaml'
need "pod lab is running" '[ "$(apodman pod inspect -f "{{.State}}" lab)" = Running ]'
need "http://127.0.0.1:8081 answers 200" 'http_ok http://127.0.0.1:8081/'
