# greg's containers and images (the dev container and its image), then the
# devcontainer CLI if the lab didn't find it, then the packages it
# installed. greg goes with users_remove, the nodes with nodes_down.
if id greg >/dev/null 2>&1; then
	runuser -l greg -c 'podman system reset -f' >/dev/null 2>&1
fi
if [ "$(state_get devcontainer-cli)" != present ] && command -v npm >/dev/null; then
	npm uninstall -g @devcontainers/cli >/dev/null 2>&1
fi
while read -r p; do dnf -y -q remove "$p" >/dev/null 2>&1; done <"$LAB_STATE/missing" 2>/dev/null
true
