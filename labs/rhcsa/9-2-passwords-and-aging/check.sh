field() { getent shadow "$1" | cut -d: -f"$2"; }
pw_is() {
	python3 -W ignore -c 'import crypt, sys; h = sys.argv[1]; sys.exit(0 if h and crypt.crypt(sys.argv[2], h) == h else 1)' "$(field dave 2)" "$1"
}

task 1 "dave's password Secret-2026, to be changed at the next login"
need "dave's password is Secret-2026" 'pw_is Secret-2026'
need "dave must change his password at the next login" '[ "$(field dave 3)" = 0 ]'

task 2 "New users' passwords expire after 90 days; existing users unchanged"
need "PASS_MAX_DAYS is 90 in /etc/login.defs" 'grep -Eq "^[[:space:]]*PASS_MAX_DAYS[[:space:]]+90[[:space:]]*$" /etc/login.defs'
need "dave's maximum password age didn't change" '[ "$(field dave 5)" = "$(state_get dave-max)" ]'
need "root's maximum password age isn't 90" '[ "$(field root 5)" != 90 ]'

task 3 "dave's account expires on 2027-12-31, with a 14-day warning"
need "dave's account expires on 2027-12-31" '[ "$(field dave 8)" = "$(( $(date -ud 2027-12-31 +%s) / 86400 ))" ]'
need "the warning period is 14 days" '[ "$(field dave 6)" = 14 ]'
