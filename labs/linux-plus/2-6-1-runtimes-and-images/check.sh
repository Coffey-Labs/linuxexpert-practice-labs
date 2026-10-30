auid=$(id -u alice 2>/dev/null)
apodman() { (cd / && runuser -u alice -- env XDG_RUNTIME_DIR=/run/user/$auid podman "$@"); }
H=localhost/hello:1.0
orig=$(printf 'import sys\nprint("hello from", sys.argv[1:])\n')
cfg() { apodman image inspect -f "$1" "$H"; }

task 1 "ubi10/ubi-minimal pulled"
need "alice has registry.access.redhat.com/ubi10/ubi-minimal" 'apodman images --format "{{.Repository}}" | grep -qx registry.access.redhat.com/ubi10/ubi-minimal'

task 2 "hello:1.0 built from ~/img"
need "~/img has app.py and a Containerfile" '[ -f /home/alice/img/app.py ] && [ -f /home/alice/img/Containerfile ]'
need "alice has the image localhost/hello:1.0" 'apodman image exists "$H"'
need "its entrypoint is python3 /opt/app.py" '[ "$(cfg "{{json .Config.Entrypoint}}")" = "[\"python3\",\"/opt/app.py\"]" ]'
need "its default argument is default" '[ "$(cfg "{{json .Config.Cmd}}")" = "[\"default\"]" ]'
need "it runs as user 1001" '[ "$(cfg "{{.Config.User}}")" = 1001 ]'
need "podman run --rm hello:1.0 works" 'apodman run --rm "$H"'

task 3 "hello:1.0 rebuilt with a changed app.py"
need "~/img/app.py has changed" '[ -f /home/alice/img/app.py ] && [ "$(cat /home/alice/img/app.py)" != "$orig" ]'
need "hello:1.0 has the changed app.py" 'apodman run --rm --entrypoint cat "$H" /opt/app.py | cmp -s - /home/alice/img/app.py'

task 4 "latest tag removed, dangling images pruned"
need "hello:1.0 is still there" 'apodman image exists "$H"'
need "there is no hello:latest" '! apodman image exists localhost/hello:latest'
need "there are no dangling images" '[ -z "$(apodman images -q -f dangling=true)" ]'
