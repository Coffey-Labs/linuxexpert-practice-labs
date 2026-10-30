as() { local u=$1; shift; runuser -u "$u" -- "$@"; }
# getfacl lines, with "#effective:" only where the mask limits an entry.
acl() { getfacl -cp "$1" 2>/dev/null | tr '\t' ' '; }
# Every ACL under a directory, in name order: getfacl -R lists files in
# directory order, which on XFS differs between a tree and its copy.
acl_tree() { (cd "$1" && find . -print0 | LC_ALL=C sort -z | xargs -0 getfacl 2>/dev/null); }

# Task 2 is tried with a new file from eve (umask 077) and one from dana
# (umask 022), removed again at once.
t2_eve='' t2_dana=''
f=/srv/project/le-lab-check-eve
if as eve bash -c "umask 077; echo x >$f" 2>/dev/null; then
	as dana test -w "$f" && t2_eve=yes
fi
rm -f "$f"
f=/srv/project/le-lab-check-dana
if as dana bash -c "umask 022; echo x >$f" 2>/dev/null; then
	as eve test -w "$f" && t2_dana=yes
fi
rm -f "$f"

task 1 "alice can read and write /srv/reports and its files"
need "alice isn't in group finance" '! id -nG alice | grep -qw finance'
need "/srv/reports and its files still belong to group finance" '[ "$(stat -c %G /srv/reports /srv/reports/q3-summary.txt /srv/reports/budget-2027.txt | sort -u)" = finance ]'
need "getfacl /srv/reports shows user:alice:rwx, not limited by the mask" 'acl /srv/reports | grep -qx "user:alice:rwx"'
need "getfacl shows user:alice:rw- on q3-summary.txt, not limited by the mask" 'acl /srv/reports/q3-summary.txt | grep -qx "user:alice:rw-"'
need "getfacl shows user:alice:rw- on budget-2027.txt, not limited by the mask" 'acl /srv/reports/budget-2027.txt | grep -qx "user:alice:rw-"'
need "alice can edit the reports" 'as alice test -r /srv/reports/q3-summary.txt -a -w /srv/reports/q3-summary.txt -a -w /srv/reports/budget-2027.txt'

task 2 "New files in /srv/project writable by devs, whatever the umask"
need "a file eve creates with umask 077 is writable by dana" '[ "$t2_eve" = yes ]'
need "a file dana creates with umask 022 is writable by eve" '[ "$t2_dana" = yes ]'

task 3 "plan.txt: the cause in /root/lab-answers/3, alice can write again"
need "/root/lab-answers/3 names the ACL entry that limits alice" 'answer 3 | grep -qw mask'
need "alice's entry is still there, user:alice:rw- with no #effective limit" 'acl /srv/shared/plan.txt | grep -qx "user:alice:rw-"'
need "alice can write to plan.txt" 'as alice test -w /srv/shared/plan.txt'

task 4 "/srv/project copied to /backup/project with its ACLs"
need "/backup/project exists" '[ -d /backup/project ]'
need "the files are the same" 'diff -r /srv/project /backup/project'
need "getfacl shows the same ACLs, owners and groups in both" 'diff <(acl_tree /srv/project) <(acl_tree /backup/project)'
