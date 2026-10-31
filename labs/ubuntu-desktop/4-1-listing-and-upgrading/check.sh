new_holds() { comm -13 "$LAB_STATE/holds-before" <(apt-mark showhold | sort); }
# The last history.log entry with an Upgrade: line that started before
# the answer was written: "YYYY-MM-DD HH:MM:SS WHO".
last_upgrade() {
	local cut f
	cut=$(date -r /root/lab-answers/3 '+%Y-%m-%d %H:%M:%S' 2>/dev/null) || return 1
	for f in $(ls /var/log/apt/history.log.*.gz 2>/dev/null | sort -t. -k3,3nr) /var/log/apt/history.log; do
		zcat -f "$f" 2>/dev/null
	done | awk -v cut="$cut" '
		/^Start-Date:/ {d = $2 " " $3; cmd = ""; req = ""; up = 0}
		/^Commandline:/ {cmd = $0}
		/^Requested-By:/ {req = $2}
		/^Upgrade:/ {up = 1}
		/^End-Date:/ {
			if (up && d <= cut) {
				who = req != "" ? req : (cmd ~ /unattended-upgrade/ ? "unattended-upgrade" : "root")
				last = d " " who
			}
		}
		END {if (last == "") exit 1; print last}'
}
when_ok() {
	local l e; l=$(sed -n 1p /root/lab-answers/3 2>/dev/null); e=$(last_upgrade) || return 1
	grep -qF -- "${e%% *}" <<<"$l" && grep -qF -- "$(cut -d' ' -f2 <<<"$e" | cut -c1-5)" <<<"$l"
}
who_ok() {
	local a e; a=$(sed -n 2p /root/lab-answers/3 2>/dev/null | tr A-Z a-z | tr -d '[:space:]'); e=$(last_upgrade | cut -d' ' -f3)
	case $e in
	unattended-upgrade) [[ $a =~ unattended|automatic|daily ]] ;;
	*) [ -n "$e" ] && [ "$a" = "$e" ] ;;
	esac
}

task 1 "Number of installed deb packages"
need "/root/lab-answers/1 has the count of installed debs (within 5%)" 'a=$(answer 1); [[ $a =~ ^[0-9]+$ ]] && for n in "$(state_get debs)" "$(dpkg -l | grep -c "^ii")"; do [ $((a * 100)) -ge $((n * 95)) ] && [ $((a * 100)) -le $((n * 105)) ] && exit 0; done; exit 1'

task 2 "Everything upgraded except one held package"
need "a package is on hold (apt-mark showhold)" '[ -n "$(new_holds)" ]'
need "dpkg -l shows the held package as hi" 'for p in $(new_holds); do [ "$(dpkg-query -W -f "\${db:Status-Abbrev}" "$p" 2>/dev/null | cut -c1-2)" = hi ] && exit 0; done; exit 1'
need "apt upgrade has nothing left to do apart from the hold (and phased updates)" 'apt-get -s -o Debug::NoLocking=1 --with-new-pkgs upgrade 2>/dev/null | grep -q "^0 upgraded, 0 newly installed"'

task 3 "When and by whom the last upgrade was run"
need "line 1 of /root/lab-answers/3 is the Start-Date (date and time) of the last upgrade" when_ok
need "line 2 is who ran it" who_ok

task 4 "Hold a snap's updates for two days, then undo it" self
