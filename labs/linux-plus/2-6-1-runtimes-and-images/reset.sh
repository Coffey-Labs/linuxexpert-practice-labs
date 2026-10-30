# alice's containers, pods, volumes and networks go with her account; stop
# them cleanly first, then her services.
if id alice >/dev/null 2>&1; then
	uid=$(id -u alice)
	(cd / && runuser -u alice -- env XDG_RUNTIME_DIR=/run/user/$uid sh -c \
		'podman pod rm -f -a; podman rm -f -a -t 0; podman volume prune -f; podman network prune -f' >/dev/null 2>&1)
	loginctl disable-linger alice 2>/dev/null
	loginctl terminate-user alice 2>/dev/null
	systemctl stop "user@$uid.service" 2>/dev/null
fi
true
