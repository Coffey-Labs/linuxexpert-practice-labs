pkg_installed podman || pkg_install podman
user_add alice
loginctl enable-linger alice
uid=$(id -u alice)
for i in $(seq 30); do [ -S /run/user/$uid/bus ] && break; sleep 1; done
