D=/srv/shared
acl_of() { getfacl -cp "$1" 2>/dev/null; }
# eff FILE ENTRY: the effective permissions of an ACL entry such as
# group:designers (its permissions masked by the mask).
eff() {
	getfacl -cpe "$1" 2>/dev/null | awk -v e="$2:" 'index($0, e) == 1 {
		n = split($0, f, "#effective:"); if (n > 1) { gsub(/[[:space:]]/, "", f[2]); print f[2] }
		else { sub(/.*:/, "", f[1]); gsub(/[[:space:]]/, "", f[1]); print f[1] } exit }'
}
try_touch() {
	local f="$D/.le-check-$1-$$"
	runuser -u "$1" -- touch "$f" 2>/dev/null || return 1
	rm -f "$f"
}

task 1 "/srv/shared: mode 750, alice reads, designers create"
need "/srv/shared is a directory" '[ -d "$D" ]'
need "it's owned by you, not by alice or bob" '! [[ "$(stat -c %U "$D")" =~ ^(alice|bob)$ ]]'
need "its owner has rwx, its group r-x and others nothing (750)" 'acl_of "$D" | grep -qx "user::rwx" && acl_of "$D" | grep -qx "group::r-x" && acl_of "$D" | grep -qx "other::---"'
need "the ACL gives alice r-x" 'acl_of "$D" | grep -qx "user:alice:r-x"'
need "the ACL gives designers rwx" 'acl_of "$D" | grep -qx "group:designers:rwx"'
need "the mask is rwx" 'acl_of "$D" | grep -qx "mask::rwx"'
need "alice can list it" 'runuser -u alice -- ls "$D"'
need "bob can create files in it" 'try_touch bob'
need "alice can't create files in it" '! try_touch alice'

task 2 "New files: designers rw-, alice r--"
probe="$D/.le-check-new-$$"
runuser -u bob -- touch "$probe" 2>/dev/null
need "bob can create a file in /srv/shared" '[ -f "$probe" ]'
need "designers can read and write it (rw-)" '[ "$(eff "$probe" group:designers)" = rw- ]'
need "alice can read it (r--)" '[ "$(eff "$probe" user:alice)" = r-- ]'
rm -f "$probe"

task 3 "/tmp/new copied with its ACL"
need "/srv/shared/new exists and belongs to bob" '[ "$(stat -c %U "$D/new" 2>/dev/null)" = bob ]'
need "/tmp/new exists" '[ -f /tmp/new ]'
need "/tmp/new still belongs to bob" '[ "$(stat -c %U /tmp/new)" = bob ]'
need "/tmp/new has the ACL entries for alice and designers" 'acl_of /tmp/new | grep -q "^user:alice:" && acl_of /tmp/new | grep -q "^group:designers:"'
