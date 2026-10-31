# Shared helpers for practice labs. Sourced by le-lab and by every lab's
# setup.sh, check.sh and reset.sh; never run on its own.

LE_LIB=$(readlink -f "${BASH_SOURCE[0]}")
LE_STATE=/var/lib/le-lab
LE_DISKS=$LE_STATE/disks
LE_PEER_NS=lepeer
LE_HOST_ADDR=10.99.0.1
LE_PEER_ADDR=10.99.0.2
LE_NODES=$LE_STATE/nodes
LE_NODE_NET=le-lab-nodes
LE_NODE_PREFIX=10.99.1
LE_NODE_BASE=quay.io/almalinuxorg/10-init:10
LE_NODE_IMAGE=localhost/le-lab-node:10

# ---- output -----------------------------------------------------------------

if [ -t 1 ]; then
	C_OK=$'\e[32m' C_BAD=$'\e[31m' C_DIM=$'\e[2m' C_B=$'\e[1m' C_0=$'\e[0m'
else
	C_OK='' C_BAD='' C_DIM='' C_B='' C_0=''
fi

say() { printf '%s\n' "$*"; }
warn() { printf '%s\n' "$*" >&2; }
die() { printf 'le-lab: %s\n' "$*" >&2; exit 1; }

# refuse MESSAGE: for setup.sh checks before it changes anything; le-lab
# then doesn't mark the lab as started, so the student can fix it and start
# again.
refuse() { printf 'le-lab: %s\n' "$*" >&2; exit 3; }

# ---- which system -----------------------------------------------------------

# OS_FAMILY is rhel or debian; OS_NAME is for messages.
. /etc/os-release
case " $ID ${ID_LIKE:-} " in
*" rhel "* | *" fedora "* | *" centos "*) OS_FAMILY=rhel ;;
*" debian "* | *" ubuntu "*) OS_FAMILY=debian ;;
*) OS_FAMILY=unknown ;;
esac
OS_NAME=${PRETTY_NAME:-$ID}

is_rhel() { [ "$OS_FAMILY" = rhel ]; }
is_debian() { [ "$OS_FAMILY" = debian ]; }

# pick RHEL-VALUE DEBIAN-VALUE: print the one for this system.
pick() { if is_rhel; then printf '%s' "$1"; else printf '%s' "$2"; fi; }

# ---- packages ---------------------------------------------------------------

# pkg_install NAME...: install quietly; names are the same on both families
# unless given as rhel-name/debian-name.
pkg_install() {
	local p names=()
	for p in "$@"; do
		case $p in
		*/*) if is_rhel; then names+=("${p%%/*}"); else names+=("${p##*/}"); fi ;;
		*) names+=("$p") ;;
		esac
	done
	say "${C_DIM}Installing ${names[*]}...${C_0}"
	if is_rhel; then
		dnf -y -q install "${names[@]}" >/dev/null
	else
		DEBIAN_FRONTEND=noninteractive apt-get -y -qq install "${names[@]}" >/dev/null 2>&1 ||
			{ apt-get -qq update >/dev/null && DEBIAN_FRONTEND=noninteractive apt-get -y -qq install "${names[@]}" >/dev/null; }
	fi
}

pkg_installed() {
	if is_rhel; then rpm -q "$1" >/dev/null 2>&1; else dpkg-query -W -f '${Status}' "$1" 2>/dev/null | grep -q 'ok installed'; fi
}

# ---- lab state --------------------------------------------------------------

# Every lab keeps its own notes in $LAB_STATE (set by le-lab): created by
# setup, read by check, removed by reset.
state_set() { mkdir -p "$LAB_STATE" && printf '%s\n' "$2" >"$LAB_STATE/$1"; }
state_get() { cat "$LAB_STATE/$1" 2>/dev/null; }

# ---- spare disks ------------------------------------------------------------

# Labs that need spare disks use loop devices backed by files, so nobody has
# to add disks to their VM. le-lab-disks.service attaches them again at
# every boot, before local filesystems are mounted, always as the same
# /dev/loopN, so fstab entries and LVM keep working after a reboot.

# disk_add N SIZE: create disk N (0-9) as /dev/loop(40+N); print the device.
disk_add() {
	local n=$1 size=$2 dev=/dev/loop$((40 + $1)) img=$LE_DISKS/disk$1.img
	mkdir -p "$LE_DISKS"
	[ -e "$img" ] && die "spare disk $n already exists; run le-lab reset first"
	truncate -s "$size" "$img"
	[ -e "$dev" ] || mknod -m 660 "$dev" b 7 $((40 + n))
	losetup -P "$dev" "$img"
	if command -v lvmdevices >/dev/null && [ -e /etc/lvm/devices/system.devices ]; then
		lvmdevices --adddev "$dev" >/dev/null 2>&1 || true
	fi
	printf '%s\n' "$dev"
}

# disks_attach: attach every spare disk again (le-lab-disks.service, at
# boot), then activate any volume groups on them.
disks_attach() {
	local img n dev
	for img in "$LE_DISKS"/disk*.img; do
		[ -e "$img" ] || continue
		n=${img##*/disk}; n=${n%.img}; dev=/dev/loop$((40 + n))
		[ -e "$dev" ] || mknod -m 660 "$dev" b 7 $((40 + n))
		losetup "$dev" >/dev/null 2>&1 || losetup -P "$dev" "$img"
	done
	udevadm settle
	command -v vgchange >/dev/null && vgchange -aay --sysinit >/dev/null 2>&1
	true
}

# disks_remove: unmount, deactivate and delete every spare disk.
disks_remove() {
	local img n dev
	for img in "$LE_DISKS"/disk*.img; do
		[ -e "$img" ] || continue
		n=${img##*/disk}; n=${n%.img}; dev=/dev/loop$((40 + n))
		# Anything mounted from the disk or its partitions, deepest first.
		findmnt -rn -o TARGET,SOURCE | awk -v d="$dev" '$2 ~ "^"d || $2 ~ "^/dev/mapper/"' |
			sort -r | while read -r tgt src; do
			if [ "${src#/dev/mapper/}" != "$src" ]; then
				lvs --noheadings -o devices "$src" 2>/dev/null | grep -q "$dev" || continue
			fi
			umount -l "$tgt" 2>/dev/null
		done
		swapoff "$dev"* 2>/dev/null
		if command -v pvs >/dev/null; then
			pvs --noheadings -o vg_name "$dev" "$dev"p* 2>/dev/null | awk 'NF{print $1}' | sort -u |
				while read -r vg; do vgchange -an "$vg" >/dev/null 2>&1; vgremove -ff "$vg" >/dev/null 2>&1; done
			pvremove -ff -y "$dev" "$dev"p* >/dev/null 2>&1
			command -v lvmdevices >/dev/null && lvmdevices --deldev "$dev" >/dev/null 2>&1
		fi
		losetup -d "$dev" 2>/dev/null
		rm -f "$img"
	done
	true
}

# ---- a second machine -------------------------------------------------------

# Tasks written for "the other VM" use a network namespace instead: a real
# network stack, reached at $LE_PEER_ADDR (name "peer") over a veth pair.
# It shares the VM's files and users, but not its addresses, routes,
# firewall or listening ports. Run commands there with in_peer; for a
# service that should run there, give its unit
# NetworkNamespacePath=/run/netns/lepeer and After=le-lab-peer.service.

peer_up() {
	# Comes back at every boot while the lab is set up.
	if [ ! -f /etc/systemd/system/le-lab-peer.service ]; then
		cat >/etc/systemd/system/le-lab-peer.service <<EOF
[Unit]
Description=LINUXexpert practice lab peer namespace
After=network-pre.target
Before=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c '. $LE_LIB && peer_up'

[Install]
WantedBy=multi-user.target
EOF
		systemctl daemon-reload
		systemctl enable --quiet le-lab-peer.service
	fi
	# NetworkManager leaves the veth alone.
	if [ -d /etc/NetworkManager/conf.d ] && [ ! -f /etc/NetworkManager/conf.d/90-le-lab.conf ]; then
		printf '[keyfile]\nunmanaged-devices=interface-name:le-host\n' >/etc/NetworkManager/conf.d/90-le-lab.conf
		systemctl reload NetworkManager 2>/dev/null || true
	fi
	ip netns list | grep -qw "$LE_PEER_NS" && return 0
	ip netns add "$LE_PEER_NS"
	ip link add le-host type veth peer name le-peer
	ip link set le-peer netns "$LE_PEER_NS"
	ip addr add "$LE_HOST_ADDR/24" dev le-host
	ip link set le-host up
	ip -n "$LE_PEER_NS" addr add "$LE_PEER_ADDR/24" dev le-peer
	ip -n "$LE_PEER_NS" link set le-peer up
	ip -n "$LE_PEER_NS" link set lo up
	ip -n "$LE_PEER_NS" route add default via "$LE_HOST_ADDR"
	hosts_add "$LE_PEER_ADDR peer.lab.example peer"
	true
}

peer_down() {
	if [ -f /etc/systemd/system/le-lab-peer.service ]; then
		systemctl disable --quiet le-lab-peer.service 2>/dev/null
		rm -f /etc/systemd/system/le-lab-peer.service
		systemctl daemon-reload
	fi
	if [ -f /etc/NetworkManager/conf.d/90-le-lab.conf ]; then
		rm -f /etc/NetworkManager/conf.d/90-le-lab.conf
		systemctl reload NetworkManager 2>/dev/null || true
	fi
	ip netns pids "$LE_PEER_NS" 2>/dev/null | xargs -r kill 2>/dev/null
	ip link del le-host 2>/dev/null
	ip netns del "$LE_PEER_NS" 2>/dev/null
	rm -rf "/etc/netns/$LE_PEER_NS"
	hosts_remove
	true
}

in_peer() { ip netns exec "$LE_PEER_NS" "$@"; }

# Lab lines in /etc/hosts sit between markers so reset can take them out
# without touching the student's own entries.
hosts_add() {
	grep -qxF "$1" /etc/hosts && return 0
	if ! grep -q '^# le-lab begin' /etc/hosts; then
		printf '# le-lab begin\n# le-lab end\n' >>/etc/hosts
	fi
	sed -i "/^# le-lab end/i $1" /etc/hosts
}

hosts_remove() { sed -i '/^# le-lab begin/,/^# le-lab end/d' /etc/hosts; }

# ---- sshd -------------------------------------------------------------------

# sshd_restart: restart sshd with its current settings, for resets that put
# its configuration back. On Ubuntu that means restarting ssh.socket, which
# restarts ssh.service too; restarting both, or doing it too often, trips the
# service's start limit and leaves nothing on port 22. So clear the counters,
# restart once, and check that port 22 answers, up to three times.
sshd_restart() {
	local unit=sshd i
	is_rhel || unit=ssh.socket
	for i in 1 2 3; do
		systemctl reset-failed "$unit" ssh.service 2>/dev/null
		systemctl restart "$unit" 2>/dev/null
		sleep 2
		listening 22 tcp && ! systemctl is-failed --quiet "$(pick sshd ssh.service)" && return 0
	done
	warn "sshd isn't listening on port 22; check 'systemctl status $unit'"
	return 1
}

# ---- managed nodes ----------------------------------------------------------

# Tasks written for "managed nodes" (a control node and several machines it
# manages over SSH) use podman containers: node1..nodeN at
# $LE_NODE_PREFIX.11, .12, ... (names in /etc/hosts), each an AlmaLinux 10
# system with systemd as PID 1, its own files, packages, users, services
# and cron, sshd, and dnf against the real AlmaLinux repositories. root and
# user "ansible" (in wheel) have password Lab-Pass-1. The containers are
# kept, not recreated, so everything done in a node survives a reboot of
# the VM; le-lab-nodes.service starts them again at boot.

# nodes_up N: set up node1..nodeN (1-9) and wait until their sshd answers.
nodes_up() {
	local n=${1:-3} i name
	case $n in [1-9]) ;; *) die "nodes_up takes 1 to 9 nodes" ;; esac
	mkdir -p "$LE_NODES"
	if ! command -v podman >/dev/null; then
		pkg_install podman
		printf 'podman\n' >"$LE_NODES/installed-podman"
	fi
	if ! podman image exists "$LE_NODE_BASE"; then
		say "${C_DIM}Pulling the node image...${C_0}"
		printf '%s\n' "$LE_NODE_BASE" >"$LE_NODES/pulled"
		for i in 1 2 3; do podman pull -q "$LE_NODE_BASE" >/dev/null && break; sleep 5; done
		podman image exists "$LE_NODE_BASE" || die "could not pull $LE_NODE_BASE"
	fi
	if ! podman image exists "$LE_NODE_IMAGE"; then
		say "${C_DIM}Building the node image...${C_0}"
		_node_build || die "could not build the node image"
	fi
	if ! podman network exists "$LE_NODE_NET"; then
		podman network create --subnet "$LE_NODE_PREFIX.0/24" --gateway "$LE_NODE_PREFIX.1" \
			--label le-lab=node "$LE_NODE_NET" >/dev/null
	fi
	for i in $(seq 1 "$n"); do
		name=node$i
		if ! podman container exists "$name"; then
			podman create --name "$name" --hostname "$name" --label le-lab=node \
				--network "$LE_NODE_NET" --ip "$LE_NODE_PREFIX.$((10 + i))" \
				--systemd always --restart always \
				--cap-add AUDIT_WRITE,AUDIT_CONTROL,NET_ADMIN,NET_RAW \
				"$LE_NODE_IMAGE" >/dev/null
		fi
		grep -qxF "$name" "$LE_NODES/names" 2>/dev/null || printf '%s\n' "$name" >>"$LE_NODES/names"
		hosts_add "$LE_NODE_PREFIX.$((10 + i)) $name.lab.example $name"
	done
	if [ ! -f /etc/systemd/system/le-lab-nodes.service ]; then
		cat >/etc/systemd/system/le-lab-nodes.service <<EOF
[Unit]
Description=LINUXexpert practice lab managed nodes
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
TimeoutStartSec=300
ExecStart=/bin/bash -c '. $LE_LIB && nodes_start'
ExecStop=/bin/bash -c '. $LE_LIB && nodes_stop'

[Install]
WantedBy=multi-user.target
EOF
		systemctl daemon-reload
		systemctl enable --quiet le-lab-nodes.service
	fi
	say "${C_DIM}Starting ${n} managed node(s)...${C_0}"
	systemctl start le-lab-nodes.service
	nodes_start
}

# The node image: the AlmaLinux 10 init image with sshd, sudo, Python and
# cron, and the two lab logins. The image starts with a copy of this VM's
# dnf metadata (the same AlmaLinux repositories), so neither the build nor
# the first dnf run in each node has to download it again. dnf in the build
# and in the nodes moves on from a mirror slower than 100 kB/s after 15 s.
_node_build() {
	local dir cache=()
	dir=$(mktemp -d)
	cat >"$dir/Containerfile" <<'EOF'
FROM base
RUN if [ -d /le-cache ]; then cp -a /le-cache/. /var/cache/dnf/; fi \
    && dnf -y -q --setopt=install_weak_deps=False --setopt=minrate=100k --setopt=timeout=15 install \
        openssh-server openssh-clients sudo python3 cronie procps-ng \
        iproute iputils hostname tar findutils less \
    && dnf clean packages
RUN useradd -m -G wheel ansible \
    && printf 'root:Lab-Pass-1\nansible:Lab-Pass-1\n' | chpasswd \
    && printf 'PermitRootLogin yes\n' >/etc/ssh/sshd_config.d/01-le-lab.conf \
    && printf '# Practice lab: move on from slow mirrors.\nminrate=100k\ntimeout=15\n' >>/etc/dnf/dnf.conf \
    && systemctl enable sshd crond
EOF
	is_rhel && [ -d /var/cache/dnf ] &&
		cache=(--security-opt label=disable -v /var/cache/dnf:/le-cache:ro)
	podman build -q --layers=false --from "$LE_NODE_BASE" "${cache[@]}" \
		-t "$LE_NODE_IMAGE" "$dir" >/dev/null
	local r=$?
	rm -rf "$dir"
	return $r
}

# nodes_names: the node names, one a line.
nodes_names() { cat "$LE_NODES/names" 2>/dev/null; }

# node_addr NAME: a node's address.
node_addr() { printf '%s.%d\n' "$LE_NODE_PREFIX" $((10 + ${1#node})); }

# nodes_start: start every node and wait for its sshd (le-lab-nodes.service,
# at boot).
nodes_start() {
	local name
	for name in $(nodes_names); do
		podman start "$name" >/dev/null || warn "le-lab: could not start $name"
	done
	nodes_wait
}

nodes_stop() {
	local names; names=$(nodes_names)
	[ -n "$names" ] && podman stop -t 15 $names >/dev/null 2>&1
	true
}

# nodes_wait [SECONDS]: wait until every node's sshd accepts connections.
nodes_wait() {
	local limit=${1:-120} t=0 name addr
	for name in $(nodes_names); do
		addr=$(node_addr "$name")
		until timeout 2 bash -c "exec 3<>/dev/tcp/$addr/22" 2>/dev/null; do
			sleep 1; t=$((t + 1))
			[ "$t" -lt "$limit" ] || { warn "le-lab: $name doesn't answer on port 22"; return 1; }
		done
	done
}

# in_node [-i] NAME CMD...: run a command as root in a node; one argument
# runs as shell code. With -i it reads standard input (for here-documents);
# without, it leaves it alone, so it is safe in a while-read loop.
in_node() {
	local i=()
	[ "$1" = -i ] && { i=(-i); shift; }
	local name=$1; shift
	if [ $# -eq 1 ]; then
		podman exec "${i[@]}" "$name" /bin/bash -c "$1"
	else
		podman exec "${i[@]}" "$name" "$@"
	fi
}

# nodes_down: remove the nodes, their unit, network and images, and podman
# itself if nodes_up installed it.
nodes_down() {
	local unit=/etc/systemd/system/le-lab-nodes.service c
	if [ -f "$unit" ]; then
		systemctl disable --quiet le-lab-nodes.service 2>/dev/null
		systemctl stop le-lab-nodes.service 2>/dev/null
		rm -f "$unit"
		systemctl daemon-reload
	fi
	if command -v podman >/dev/null; then
		for c in $(podman ps -a --filter label=le-lab=node --format '{{.Names}}'); do
			podman rm -f -t 5 "$c" >/dev/null 2>&1
		done
		podman network rm -f "$LE_NODE_NET" >/dev/null 2>&1
		podman rmi -f "$LE_NODE_IMAGE" >/dev/null 2>&1
		if [ -f "$LE_NODES/pulled" ]; then
			podman rmi -f "$(cat "$LE_NODES/pulled")" >/dev/null 2>&1
		fi
		if [ -f "$LE_NODES/installed-podman" ]; then
			podman system reset -f >/dev/null 2>&1
			if is_rhel; then dnf -y -q remove podman >/dev/null 2>&1
			else apt-get -y -qq purge podman >/dev/null 2>&1 && apt-get -y -qq autoremove >/dev/null 2>&1; fi
			# What podman left behind; there was none of it before.
			if ! pkg_installed podman; then
				rm -rf /var/lib/containers /etc/containers/networks
				rmdir /etc/containers 2>/dev/null
			fi
		fi
	fi
	[ -d "$LE_NODES" ] && hosts_remove
	rm -rf "$LE_NODES"
	true
}

# ---- users ------------------------------------------------------------------

# user_add NAME [useradd options]: create a lab user if missing, with bash
# as the shell unless -s is given (Debian's useradd default is sh) and
# password "Lab-Pass-1" so students can log in as them.
user_add() {
	local u=$1; shift
	id "$u" >/dev/null 2>&1 && return 0
	case " $* " in *" -s "* | *" --shell "*) ;; *) set -- -s /bin/bash "$@" ;; esac
	useradd -m "$@" "$u"
	echo "$u:Lab-Pass-1" | chpasswd
	printf '%s\n' "$u" >>"$LAB_STATE/users"
}

users_remove() {
	local u
	[ -f "$LAB_STATE/users" ] || return 0
	while read -r u; do
		pkill -KILL -u "$u" 2>/dev/null
		userdel -r "$u" 2>/dev/null
	done <"$LAB_STATE/users"
	true
}

# as_user NAME CMD...: run CMD as NAME with a login environment. runuser
# applies pam_limits but not pam_env (/etc/environment); for checks that
# need both, use sudo -niu NAME.
as_user() { local u=$1; shift; runuser -l "$u" -c "$*"; }

# ---- grading (check.sh) -----------------------------------------------------

# A check.sh is a list of tasks, each followed by the things that must be
# true for it to pass:
#
#   task 1 "Create user carol with UID 2001"
#   need "carol has UID 2001" '[ "$(id -u carol)" = 2001 ]'
#   need "carol is in developers" 'id -nG carol | grep -qw developers'
#   need "sshd is running" active sshd
#
#   task 2 "..." rhel      # graded only on RHEL-family systems
#   task 3 "..." self      # not graded: the student checks it themselves
#
# A check given as one quoted string runs as shell code (pipes, !, $(...));
# several words run as a command. Output is hidden, and the first failing
# need of a task is shown as the hint. Grading is rough on purpose: it looks
# at the result, not at how you got there.

_task_n='' _task_title='' _task_mode='' _task_failed='' _task_skipped=''
_passed=0 _total=0 _results=()

_task_finish() {
	[ -n "$_task_n" ] || return 0
	local line
	if [ "$_task_mode" = self ]; then
		line=$(printf '  %s[SELF]%s %-3s %s' "$C_DIM" "$C_0" "$_task_n" "$_task_title")
	elif [ -n "$_task_skipped" ]; then
		line=$(printf '  %s[SKIP]%s %-3s %s %s(%s only)%s' "$C_DIM" "$C_0" "$_task_n" "$_task_title" "$C_DIM" "$_task_skipped" "$C_0")
	elif [ -n "$_task_failed" ]; then
		_total=$((_total + 1))
		line=$(printf '  %s[FAIL]%s %-3s %s\n         %snot yet: %s%s' "$C_BAD" "$C_0" "$_task_n" "$_task_title" "$C_DIM" "$_task_failed" "$C_0")
	else
		_total=$((_total + 1)) _passed=$((_passed + 1))
		line=$(printf '  %s[PASS]%s %-3s %s' "$C_OK" "$C_0" "$_task_n" "$_task_title")
	fi
	_results+=("$line")
	_task_n=''
}

task() {
	_task_finish
	_task_n=$1 _task_title=$2 _task_mode=${3:-} _task_failed='' _task_skipped=''
	case $_task_mode in
	rhel) is_rhel || _task_skipped='RHEL family' ;;
	debian) is_debian || _task_skipped='Debian and Ubuntu' ;;
	esac
}

need() {
	local what=$1; shift
	[ -n "$_task_n" ] || die "need before task in check.sh"
	[ "$_task_mode" = self ] || [ -n "$_task_skipped" ] || [ -n "$_task_failed" ] && return 0
	local ok
	if [ $# -eq 1 ]; then
		(eval "$1") >/dev/null 2>&1 </dev/null && ok=1
	else
		("$@") >/dev/null 2>&1 </dev/null && ok=1
	fi
	[ -n "${ok:-}" ] || _task_failed=$what
	return 0
}

# Called by le-lab after check.sh has run.
grade_report() {
	_task_finish
	local r
	for r in "${_results[@]}"; do printf '%s\n' "$r"; done
	printf '\n'
	if [ "$_total" -eq 0 ]; then
		printf 'Nothing to grade on %s.\n' "$OS_NAME"
	else
		printf '%sScore: %d of %d tasks (%d%%)%s\n' "$C_B" "$_passed" "$_total" $((_passed * 100 / _total)) "$C_0"
	fi
	printf 'SCORE %d/%d\n' "$_passed" "$_total" >"$LE_STATE/last-score"
	[ "$_passed" -eq "$_total" ]
}

# ---- small checks used by many labs -----------------------------------------

# file_has FILE REGEX: FILE exists and a line matches the extended regex.
file_has() { [ -f "$1" ] && grep -Eq "$2" "$1"; }

# conf_has DIR-OR-FILE... REGEX: some file matches (ignoring comments).
conf_has() {
	local re=${!#} f
	for f in "${@:1:$#-1}"; do
		[ -e "$f" ] || continue
		grep -rhEv '^[[:space:]]*#' "$f" 2>/dev/null | grep -Eq "$re" && return 0
	done
	return 1
}

active() { systemctl is-active --quiet "$1"; }
enabled() { [ "$(systemctl is-enabled "$1" 2>/dev/null)" = enabled ]; }

# listening PORT [tcp|udp]: something listens on PORT.
listening() { ss -Hln"${2:0:1}" "sport = :$1" | grep -q .; }

# answer N: the student's answer from /root/lab-answers/N (first line,
# lowercase, spaces trimmed).
answer() {
	head -n1 "/root/lab-answers/$1" 2>/dev/null | tr 'A-Z' 'a-z' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}
