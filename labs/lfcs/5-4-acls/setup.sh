command -v setfacl >/dev/null || pkg_install acl
groupadd -f finance
groupadd -f devs
user_add alice -s /bin/bash
user_add bob -s /bin/bash -G finance
user_add dana -s /bin/bash -G devs
user_add eve -s /bin/bash -G devs

# Task 1: reports for group finance only.
mkdir -p /srv/reports
echo "Q3 summary" >/srv/reports/q3-summary.txt
echo "Budget 2027" >/srv/reports/budget-2027.txt
chown -R bob:finance /srv/reports
chown root:finance /srv/reports
chmod 2770 /srv/reports
chmod 660 /srv/reports/*.txt

# Tasks 2 and 4: the team's project, some of it with ACLs already.
mkdir -p /srv/project/src /srv/project/docs
echo 'int main(void) { return 0; }' >/srv/project/src/main.c
echo "# Design" >/srv/project/docs/design.md
echo "Project notes" >/srv/project/README
chown -R dana:devs /srv/project
chown root:devs /srv/project
chmod 2775 /srv/project /srv/project/src /srv/project/docs
chmod 664 /srv/project/README /srv/project/src/main.c /srv/project/docs/design.md
setfacl -m u:alice:r /srv/project/docs/design.md
setfacl -m u:alice:rx -m d:u:alice:rx /srv/project/docs

# Task 3: an entry for alice, limited by a chmod since.
mkdir -p /srv/shared
chmod 755 /srv/shared
echo "Plan" >/srv/shared/plan.txt
chown bob:bob /srv/shared/plan.txt
setfacl -m u:alice:rw /srv/shared/plan.txt
chmod 640 /srv/shared/plan.txt
