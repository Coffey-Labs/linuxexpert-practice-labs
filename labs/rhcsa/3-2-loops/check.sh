B=/usr/local/bin
run() { timeout 60 "$@" 2>/dev/null; }
# Normalize NAME SIZE lines: file name without its path, one space.
norm() { awk 'NF >= 2 {n = $1; sub(".*/", "", n); print n, $2}' | sort; }
mkusers_again() {
	local before after o
	before=$(getent passwd | sort | md5sum)
	o=$(timeout 60 $B/mkusers 2>&1)
	after=$(getent passwd | sort | md5sum)
	[ "$before" = "$after" ] || return 1
	! grep -v "already exists" <<<"$o" | grep -Eiq "error|fail|invalid|usage|cannot|not found"
}

task 1 "mkusers creates the users in /root/users.txt"
need "$B/mkusers exists and is executable" '[ -x $B/mkusers ]'
need "users kim, lee and max exist" 'id kim && id lee && id max'
need "each name is in /etc/passwd once" 'for u in kim lee max dora; do [ "$(grep -c "^$u:" /etc/passwd)" = 1 ] || exit 1; done'
need "no user with an empty or odd name was made" '! grep -q "^:" /etc/passwd'
need "run again, it creates nothing and prints no other errors" mkusers_again

task 2 "bigfiles lists files in /etc over 10000 bytes"
need "$B/bigfiles exists and is executable" '[ -x $B/bigfiles ]'
need "its list matches find /etc -maxdepth 1 -type f -size +10000c" 'diff -q <(run $B/bigfiles | norm) <(find /etc -maxdepth 1 -type f -size +10000c -printf "%f %s\n" | sort)'

task 3 "regular-users lists users with UID 1000 or more"
need "$B/regular-users exists and is executable" '[ -x $B/regular-users ]'
need "its output matches the users with UID 1000 or more in /etc/passwd, in order" 'diff -q <(run $B/regular-users | tr -s " \t" "  ") <(awk -F: "\$3 >= 1000 {print \$1, \$6}" /etc/passwd)'

task 4 "updown prints up or down for each host"
need "$B/updown exists and is executable" '[ -x $B/updown ]'
need "localhost shows up" 'run $B/updown localhost nosuchhost.invalid 127.0.0.1 | grep -qx "localhost up"'
need "127.0.0.1 shows up" 'run $B/updown localhost nosuchhost.invalid 127.0.0.1 | grep -qx "127.0.0.1 up"'
need "a made-up name shows down" 'run $B/updown localhost nosuchhost.invalid 127.0.0.1 | grep -qx "nosuchhost.invalid down"'
