nodes_wait 60 || true
# repos NODE: an enabled BaseOS and an enabled AppStream repository, both
# with signature checking (dnf's own reading of the configuration).
repos() {
	in_node "$1" "python3 -c '
import sys, dnf
b = dnf.Base(); b.conf.read(); b.read_all_repos()
found = set()
for r in b.repos.iter_enabled():
    where = \" \".join(list(r.baseurl) + [r.mirrorlist or \"\", r.metalink or \"\"]).lower()
    for k in (\"baseos\", \"appstream\"):
        if k in where and r.gpgcheck:
            found.add(k)
sys.exit(found != {\"baseos\", \"appstream\"})'"
}

task 1 "BaseOS and AppStream repositories with signature checking on every node"
for n in $(nodes_names); do
	need "$n has enabled BaseOS and AppStream repositories with gpgcheck on" repos $n
	need "dnf on $n finds packages in them (dnf repoquery zip)" "in_node $n 'dnf -q repoquery --available zip' | grep -q zip"
done

task 2 "A package group on the database servers, php and mariadb on the web servers"
need "node2 has a package group installed (dnf group list --installed)" "in_node node2 'dnf -q group list --installed' | grep -q '^ '"
need "php and mariadb are installed on node1" 'in_node node1 rpm -q php mariadb'

task 3 "Every package on the web servers is up to date"
OLD=$(state_get old-pkg)
need "node1 has its repositories (task 1)" repos node1
need "$OLD on node1 has been upgraded" "[ \"\$(in_node node1 rpm -q $OLD)\" != \"$(state_get old-ver)\" ]"
need "dnf check-update on node1 finds nothing to update" 'in_node node1 dnf -q check-update'
