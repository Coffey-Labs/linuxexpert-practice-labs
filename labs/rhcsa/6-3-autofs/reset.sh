# autofs: stop it (if the lab's tasks started it) and drop the lab's maps.
[ "$(state_get autofs-enabled)" = yes ] || systemctl disable --now autofs >/dev/null 2>&1
for f in /etc/auto.master /etc/auto.master.d/*.autofs; do
	[ -f "$f" ] || continue
	awk '!/^[[:space:]]*#/ && ($1 == "/shares" || $1 == "/rhome" || $1 == "/-") {print $1, $2}' "$f" | while read -r mp map; do
		case $map in /etc/auto.master*) continue ;; /*) ;; *) continue ;; esac
		[ "$mp" != /- ] || grep -qs /mnt/direct "$map" || continue
		rm -f "$map"
	done
	sed -i -E '\#^[[:space:]]*(/shares|/rhome|/-)[[:space:]]#d' "$f"
	case $f in *.autofs) grep -qEv '^[[:space:]]*(#|$)' "$f" || rm -f "$f" ;; esac
done
[ "$(state_get autofs-enabled)" = yes ] && systemctl restart autofs >/dev/null 2>&1
findmnt -rn -o TARGET | grep -E '^(/shares|/rhome|/mnt/direct)' | sort -r | xargs -r -n1 umount -l 2>/dev/null
systemctl disable --now le-lab-nfs-server.service >/dev/null 2>&1
rm -f /etc/systemd/system/le-lab-nfs-server.service /etc/exports.d/le-lab.exports
systemctl daemon-reload
# alice's home goes back where it was before userdel removes her.
usermod -d /home/alice alice 2>/dev/null
rm -rf /exports
rmdir /shares /rhome /mnt/direct 2>/dev/null
true
