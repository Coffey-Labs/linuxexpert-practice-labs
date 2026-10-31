gitver=$(state_get git-version)
ppa_listed() { grep -rhs '^[^#]*git-core/ppa' /etc/apt/sources.list /etc/apt/sources.list.d/ | grep -q .; }
# apt (not dpkg) installed hello since setup.
apt_installed_hello() {
	awk -v s="$(state_get since)" '
		/^Start-Date:/ {d = $2 "  " $3; in_lab = (d >= s)}
		in_lab && /^Install:/ && / hello:/ {ok = 1}
		END {exit !ok}' /var/log/apt/history.log 2>/dev/null
}
revisions() { snap list --all hello 2>/dev/null | awk 'NR > 1 && $1 == "hello"' | wc -l; }

task 1 "git-core PPA's git version found, PPA removed, git not upgraded"
need "/root/lab-answers/1 has the PPA's git version (newer, with ppa in it)" 'a=$(answer 1); [[ $a == *ppa* ]] && dpkg --compare-versions "$a" gt "$gitver"'
need "the PPA is no longer in apt's sources" '! ppa_listed'
need "git is still the version from before ($gitver)" '[ "$(dpkg-query -W -f "\${Version}" git)" = "$gitver" ]'
need "git's candidate is the archive's version again (apt update)" '! apt-cache policy git | grep -q "Candidate:.*ppa"'

task 2 "hello installed from a downloaded .deb with dpkg"
need "hello is installed (dpkg -l shows ii)" '[ "$(dpkg-query -W -f "\${db:Status-Abbrev}" hello 2>/dev/null | cut -c1-2)" = ii ]'
need "hello prints Hello, world!" '[ "$(/usr/bin/hello)" = "Hello, world!" ]'
need "it was installed with dpkg, not apt" '! apt_installed_hello'

task 3 "hello snap back on stable after edge"
need "the hello snap is installed" 'snap list hello'
need "it tracks latest/stable" '[ "$(snap list hello | awk "NR == 2 {print \$4}")" = latest/stable ]'
need "snap list --all shows two revisions (edge and stable)" '[ "$(revisions)" -ge 2 ]'
