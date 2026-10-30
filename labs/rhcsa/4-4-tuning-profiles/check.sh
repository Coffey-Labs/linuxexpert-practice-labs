LOG=/var/log/tuned/tuned.log
# tuned's log since the lab started (all of it if it was rotated).
since_start() {
	local o; o=$(state_get log-offset)
	[ -f $LOG ] || return 0
	if [ "$(stat -c %s $LOG)" -ge "${o:-0}" ]; then tail -c +$((${o:-0} + 1)) $LOG; else cat $LOG; fi
}
REC=$(tuned-adm recommend 2>/dev/null)

task 1 "The recommended profile set"
need "tuned recommends a profile" '[ -n "$REC" ]'
need "tuned applied the recommended profile ($REC) since the lab started" 'since_start | grep -qF "static tuning from profile '\''$REC'\'' applied"'

task 2 "powersave active, and kept across reboots"
need "tuned is running" active tuned
need "tuned starts at boot" enabled tuned
need "tuned-adm active shows powersave" 'tuned-adm active | grep -qx "Current active profile: powersave"'
need "powersave is the saved choice (/etc/tuned/active_profile)" '[ "$(cat /etc/tuned/active_profile)" = powersave ]'

task 3 "tuned stopped, then enabled and running again"
need "tuned was stopped since the lab started" 'since_start | grep -q "terminating TuneD"'
need "tuned is enabled and running again" 'enabled tuned && active tuned'
need "tuned-adm active shows the profile you chose" 'tuned-adm active | grep -qx "Current active profile: $(cat /etc/tuned/active_profile)"'
