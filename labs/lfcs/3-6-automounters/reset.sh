# autofs: stop it (if the lab's tasks started it) and drop the lab's maps.
[ "$(state_get autofs-enabled)" = yes ] || systemctl disable --now autofs >/dev/null 2>&1
for f in /etc/auto.master /etc/auto.master.d/*.autofs; do
	[ -f "$f" ] || continue
	awk '!/^[[:space:]]*#/ && ($1 == "/home/remote" || $1 == "/-") {print $1, $2}' "$f" | while read -r mp map; do
		case $map in /etc/auto.master*) continue ;; /*) ;; *) continue ;; esac
		[ "$mp" = /home/remote ] || grep -qs /mnt/share "$map" || continue
		rm -f "$map"
	done
	sed -i -E '\#^[[:space:]]*(/home/remote|/-)[[:space:]]#d' "$f"
	case $f in *.autofs) grep -qEv '^[[:space:]]*(#|$)' "$f" || rm -f "$f" ;; esac
done
for m in /mnt/share /home/remote/alice /home/remote/bob /home/remote; do
	findmnt -n "$m" >/dev/null 2>&1 && umount -l "$m"
done
# systemd automount: the /data line.
systemctl stop data.automount data.mount 2>/dev/null
awk '/^[[:space:]]*#/ || NF < 2 { print; next } $2 == "/data" { next } { print }' /etc/fstab >/etc/fstab.le-lab &&
	cat /etc/fstab.le-lab >/etc/fstab
rm -f /etc/fstab.le-lab
# The server.
systemctl disable --now le-lab-nfs1.service >/dev/null 2>&1
rm -f /etc/systemd/system/le-lab-nfs1.service /etc/exports.d/le-lab.exports
systemctl daemon-reload
# alice's home goes back where it was before userdel removes her.
usermod -d /home/alice alice 2>/dev/null
rm -rf /srv/share /export/home
rmdir /export /mnt/share /home/remote /data 2>/dev/null
true
