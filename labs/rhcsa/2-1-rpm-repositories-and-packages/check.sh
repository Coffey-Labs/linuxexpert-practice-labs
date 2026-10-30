REPOS=/etc/yum.repos.d
# The packages the undo put back: the Install lines of its transaction.
undo_installed() {
	local first id
	first=$(state_get history-id)
	for id in $(dnf -q history list 2>/dev/null | awk -v f="${first:-0}" '$1 ~ /^[0-9]+$/ && $1 > f {print $1}'); do
		dnf -q history info "$id" 2>/dev/null | grep -Eq '^Command Line *: .*history +(undo|rollback)' || continue
		local pkgs
		pkgs=$(dnf -q history info "$id" | awk '$1 == "Install" {print $2}')
		[ -n "$pkgs" ] || continue
		rpm -q $pkgs >/dev/null && return 0
	done
	return 1
}

task 1 "extras-mirror disabled, its file kept"
need "$REPOS/extras-mirror.repo still exists" '[ -f $REPOS/extras-mirror.repo ]'
need "extras-mirror is disabled" 'dnf -q repolist --disabled | awk "{print \$1}" | grep -qx extras-mirror'
need "dnf loads its repositories again (dnf makecache)" 'timeout 300 dnf -q makecache'

task 2 "Repository lab, served from the peer, with a package installed from it"
need "$REPOS/lab.repo defines repository lab" 'grep -qx "\[lab\]" $REPOS/lab.repo'
need "lab is enabled" 'dnf -q repolist --enabled | awk "{print \$1}" | grep -qx lab'
need "lab's baseurl points at the peer" 'grep -Eq "^baseurl *= *(http|ftp)s?://(10\.99\.0\.2|peer|peer\.lab\.example)[:/]" $REPOS/lab.repo'
need "lab checks signatures (gpgcheck=1)" 'grep -Eiq "^gpgcheck *= *(1|yes|true)" $REPOS/lab.repo'
need "dnf repoinfo lab finds packages in it" 'n=$(timeout 120 dnf -q --refresh --repo lab repoquery 2>/dev/null | wc -l); [ "$n" -gt 0 ]'
need "one of lab's packages, not installed before, is installed now" 'timeout 120 dnf -q --repo lab repoquery --qf "%{name}-%{version}-%{release}.%{arch}" 2>/dev/null | sort -u | grep -vxFf "$LAB_STATE/rpms" | xargs -r rpm -q 2>/dev/null | grep -qv "not installed"'

task 3 "semanage installed"
need "semanage --help runs" 'semanage --help'
need "rpm -qf names its package" 'rpm -qf "$(command -v semanage)"'

task 4 "A removal undone from dnf's history"
need "a dnf history undo (or rollback) put a package back, and it's installed" undo_installed
