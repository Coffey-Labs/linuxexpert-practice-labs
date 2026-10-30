[ -e /srv/lab ] && refuse "/srv/lab already exists; move it away and start again"
command -v setfacl >/dev/null || pkg_install acl
user_add permtest
mkdir -p /srv/lab/inner
echo data >/srv/lab/inner/f.txt
chmod 644 /srv/lab/inner/f.txt
chmod 700 /srv/lab
# Task 2: rw for permtest, but a mask of r.
setfacl -m u:permtest:rw /srv/lab/inner/f.txt
setfacl -m m::r /srv/lab/inner/f.txt
# Task 3: an immutable file.
echo 'Q3 report, superseded' >/srv/lab/inner/old-report.txt
chattr +i /srv/lab/inner/old-report.txt
# Task 4: no shell, and an expired account.
usermod -s "$(command -v nologin)" permtest
chage -E 0 permtest
true
