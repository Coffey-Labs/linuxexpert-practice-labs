sh_field() { getent shadow "$1" | cut -d: -f"$2"; }
# try PASSWORD: root's chpasswd sets it for pwtest.
try() { echo "pwtest:$1" | chpasswd >/dev/null 2>&1; }
NEXT_END=$(( $(date -ud "$(( $(date +%Y) + 1 ))-12-31" +%s) / 86400 ))
new_user_max() {
	local u=lecheck$$ m
	useradd -M -s /usr/sbin/nologin "$u" >/dev/null 2>&1 || return 1
	m=$(sh_field "$u" 5)
	userdel "$u" >/dev/null 2>&1
	[ "$m" = 120 ]
}

task 1 "pam_pwquality: 10 characters, a digit and an uppercase letter, for root too"
need "libpam-pwquality is installed" 'pkg_installed libpam-pwquality'
need "/etc/pam.d/common-password uses pam_pwquality" 'grep -Eq "^[[:space:]]*password[[:space:]].*pam_pwquality\.so" /etc/pam.d/common-password'
need "even root can't set xq7#lvm-pztw (no uppercase letter)" '! try "xq7#lvm-pztw"'
need "even root can't set Xq#Lvm-PzTw (no digit)" '! try "Xq#Lvm-PzTw"'
need "even root can't set Xq7#Lvm2Z (only 9 characters)" '! try "Xq7#Lvm2Z"'
need "echo pwtest:lowercase12 | chpasswd fails" '! try lowercase12'
need "echo pwtest:Kettle7-Harbor | chpasswd succeeds" 'try Kettle7-Harbor'

task 2 "alice: maximum 60, warning 10, account expires Dec 31 next year, change at next login"
need "alice's maximum password age is 60 days" '[ "$(sh_field alice 5)" = 60 ]'
need "alice is warned 10 days before" '[ "$(sh_field alice 6)" = 10 ]'
need "alice's account expires on the last day of next year" '[ "$(sh_field alice 8)" = "$NEXT_END" ]'
need "alice must change her password at next login" '[ "$(sh_field alice 3)" = 0 ]'

task 3 "New accounts' passwords expire after 120 days; existing users unchanged"
need "/etc/login.defs sets PASS_MAX_DAYS 120" '[ "$(awk "\$1 == \"PASS_MAX_DAYS\" {v = \$2} END {print v}" /etc/login.defs)" = 120 ]'
need "a new account gets maximum 120" new_user_max
need "existing users are unchanged: root's and pwtest's maximum are as before" '[ "$(sh_field root 5)" = "$(cat "$LAB_STATE/max-root")" ] && [ "$(sh_field pwtest 5)" = "$(cat "$LAB_STATE/max-pwtest")" ]'
need "alice's maximum isn't 120" '[ "$(sh_field alice 5)" != 120 ]'
