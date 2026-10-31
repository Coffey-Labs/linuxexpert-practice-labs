hpid() { systemctl show -p MainPID --value hello.service 2>/dev/null; }
# web_up: something answers on localhost:8080 within about 20 seconds
# (python's http.server can take a while to start listening).
web_up() {
	local i
	for i in $(seq 20); do
		curl -s --max-time 2 http://localhost:8080/ | grep -qi '<html\|<!DOCTYPE' && return 0
		sleep 1
	done
	return 1
}

task 1 "nginx installed, masked and unmasked: enabled and running"
need "nginx is installed" pkg_installed nginx
need "nginx isn't masked" '[ "$(systemctl is-enabled nginx 2>/dev/null)" != masked ]'
need "nginx is enabled at boot" enabled nginx
need "nginx is running" active nginx

task 2 "hello.service: http.server on 8080 from /tmp as nobody, at boot"
need "hello.service exists" 'systemctl cat hello.service'
need "hello.service is enabled at boot" enabled hello.service
need "hello.service is running" active hello.service
need "it runs python3 -m http.server 8080" 'systemctl show -p ExecStart --value hello.service | grep -Eq "python3.* -m +http\.server +8080"'
need "its main process runs as nobody" '[ "$(ps -o user= -p "$(hpid)" | tr -d " ")" = nobody ]'
need "its main process works in /tmp" '[ "$(readlink /proc/$(hpid)/cwd)" = /tmp ]'
need "curl -s localhost:8080 prints HTML" web_up

task 3 "A drop-in restarts hello 3 seconds after it fails"
need "hello.service has a drop-in" 'systemctl show -p DropInPaths --value hello.service | grep -q "hello\.service\.d/"'
need "it restarts after a failure (Restart=)" 'case $(systemctl show -p Restart --value hello.service) in on-failure|always|on-abnormal|on-abort) true ;; *) false ;; esac'
need "it waits 3 seconds first (RestartSec=3)" '[ "$(systemctl show -p RestartUSec --value hello.service)" = 3s ]'
