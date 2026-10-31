D=/srv/dac
cd $D 2>/dev/null || cd /
mode() { stat -c %a "$1" 2>/dev/null; }
owner() { stat -c %U:%G "$1" 2>/dev/null; }
acl() { getfacl -cp "$1" 2>/dev/null | grep -v '^#'; }

task 1 "id-suid: a setuid copy of id owned by bob"
need "$D/id-suid is a copy of id" 'cmp -s id-suid "$(readlink -f "$(command -v id)")"'
need "it's owned by bob, with the setuid bit" '[ "$(stat -c %U id-suid)" = bob ] && [ -u id-suid ]'
need "alice running it has bob's effective user ID" '[ "$(runuser -u alice -- $D/id-suid -u)" = "$(id -u bob)" ]'
need "the owner's execute bit is off (a capital S)" 'stat -c %A id-suid | grep -q "^...S"'

task 2 "shared: root:projects, 3770, files by alice and bob"
need "$D/shared is owned by root:projects, mode 3770" '[ "$(owner shared)" = root:projects ] && [ "$(mode shared)" = 3770 ]'
need "shared/alice.txt belongs to alice and group projects" '[ "$(owner shared/alice.txt)" = alice:projects ]'
need "shared/bob.txt belongs to bob and group projects" '[ "$(owner shared/bob.txt)" = bob:projects ]'
need "bob isn't in projects any more" '! id -nG bob | grep -qw projects'

task 3 "plan.txt: an ACL for bob, limited by the mask"
need "plan.txt belongs to alice:projects, base mode 640" '[ "$(owner plan.txt)" = alice:projects ] && acl plan.txt | grep -qx "user::rw-" && acl plan.txt | grep -qx "other::---"'
need "the ACL gives bob rw" 'acl plan.txt | grep -Eq "^user:bob:rw-"'
need "the mask is r--" 'acl plan.txt | grep -qx "mask::r--"'
need "bob can read it" 'runuser -u bob -- cat $D/plan.txt'
need "bob can't write it" '! runuser -u bob -- test -w $D/plan.txt'

task 4 "reports/q3.txt got its ACL from a default ACL, since removed"
need "reports/q3.txt has user:bob:r--" 'acl reports/q3.txt | grep -Eq "^user:bob:r--"'
need "reports/q3.txt has group:projects:rw-" 'acl reports/q3.txt | grep -Eq "^group:projects:rw-"'
need "reports has no default ACL now" '! getfacl -cp reports 2>/dev/null | grep -q "^default:"'

task 5 "ACL backup, restore, and two copies"
need "acl-backup.txt holds the ACLs of reports, q3.txt and plan.txt" 'grep -q "^# file: reports$" acl-backup.txt && grep -q "^# file: reports/q3.txt$" acl-backup.txt && grep -q "^# file: plan.txt$" acl-backup.txt'
need "the backup has bob's entry on plan.txt" 'sed -n "/^# file: plan.txt$/,/^$/p" acl-backup.txt | grep -q "^user:bob:rw-"'
need "plain-copy.txt has no ACL" '[ -f plain-copy.txt ] && ! acl plain-copy.txt | grep -q "^user:bob"'
need "full-copy.txt kept the ACL" 'acl full-copy.txt | grep -q "^user:bob:rw-"'

task 6 "user.reviewed on shared/alice.txt; cap_net_raw on id-suid; not immutable"
need "shared/alice.txt has user.reviewed=2026-10-23" '[ "$(getfattr --only-values -n user.reviewed shared/alice.txt 2>/dev/null)" = 2026-10-23 ]'
need "id-suid has cap_net_raw (permitted and effective)" 'getcap id-suid | grep -Eq "cap_net_raw[=+]ep"'
need "it's stored as security.capability" 'getfattr -n security.capability id-suid >/dev/null 2>&1'
need "plan.txt isn't immutable any more" '! lsattr -d plan.txt 2>/dev/null | cut -d" " -f1 | grep -q i'
