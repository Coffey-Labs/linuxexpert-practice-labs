# The running container publishing container port 80 on host port PORT.
on_port() {
	local c
	for c in $(podman ps -q 2>/dev/null); do
		podman port "$c" 2>/dev/null | grep -Eq "^80/tcp -> .*:$1\$" && { echo "$c"; return; }
	done
}
page() {
	local i
	for i in 1 2 3; do
		curl -s --max-time 3 "http://localhost:$1/" | grep -qi "$2" && return 0
		sleep 2
	done
	return 1
}
psql_tables() { podman exec db psql -U postgres -tAc "select count(*) from information_schema.tables where table_schema = 'public'" 2>/dev/null | tr -d ' '; }
created() { podman "$1" inspect -f "{{.$2.Unix}}" "$3" 2>/dev/null; }

task 1 "nginx in a container on host port 8080"
need "podman is installed" 'command -v podman'
need "a running container publishes port 80 on host port 8080" '[ -n "$(on_port 8080)" ]'
need "it runs an nginx image" 'podman inspect -f "{{.ImageName}}" "$(on_port 8080)" | grep -q nginx'
need "curl localhost:8080 gets nginx's page" 'page 8080 nginx'

task 2 "Image mysite:1.0 built from ~/mysite/Dockerfile and running on 8081"
need "/root/mysite/Dockerfile exists" '[ -f /root/mysite/Dockerfile ]'
need "podman images lists localhost/mysite:1.0" 'podman image exists localhost/mysite:1.0'
need "a container from mysite:1.0 publishes port 80 on host port 8081" '[ "$(podman inspect -f "{{.Image}}" "$(on_port 8081)" 2>/dev/null)" = "$(podman image inspect -f "{{.Id}}" localhost/mysite:1.0)" ]'
need "curl localhost:8081 gets a page" 'page 8081 "<"'

task 3 "PostgreSQL's table kept in volume dbdata across a new container"
need "volume dbdata exists" 'podman volume exists dbdata'
need "a container named db is running" '[ "$(podman inspect -f "{{.State.Running}}" db 2>/dev/null)" = true ]'
need "db keeps /var/lib/postgresql in volume dbdata" 'podman inspect -f "{{range .Mounts}}{{println .Name .Destination}}{{end}}" db | grep -qx "dbdata /var/lib/postgresql"'
need "the database has a table" '[ "$(psql_tables)" -ge 1 ]'
need "db is a newer container than the volume" '[ $(( $(created container Created db) - $(created volume CreatedAt dbdata) )) -ge 5 ]'

task 4 "PID 1 in an alpine container in /root/lab-answers/4"
need "an alpine image was pulled" 'podman images --format "{{.Repository}}" | grep -q "/alpine$"'
need "the answer is the command running as PID 1" '[ "$(answer 4)" = ps ]'
