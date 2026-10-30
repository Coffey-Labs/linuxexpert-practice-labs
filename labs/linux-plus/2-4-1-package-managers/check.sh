owner=$(if is_rhel; then rpm -qf --qf '%{NAME}\n' /usr/bin/ssh; else dpkg -S /usr/bin/ssh | cut -d: -f1; fi 2>/dev/null)
h0=$(state_get history)
tree_installed() {
	if is_rhel; then dnf history list tree 2>/dev/null | awk -F'|' -v h="${h0:-0}" '$1+0 > h && $4 ~ /Install/' | grep -q .
	else tail -n +"$((h0 + 1))" /var/log/apt/history.log | grep -q '^Install: .*\btree:'; fi
}
tree_removed() {
	if is_rhel; then dnf history list tree 2>/dev/null | awk -F'|' -v h="${h0:-0}" '$1+0 > h && $4 ~ /Remove|Erase/' | grep -q .
	else tail -n +"$((h0 + 1))" /var/log/apt/history.log | grep -Eq '^(Remove|Purge): .*\btree:'; fi
}

task 1 "The package that owns /usr/bin/ssh"
need "/root/lab-answers/1 names the package" '[ -n "$owner" ] && [ "$(answer 1)" = "$owner" ]'

task 2 "tree installed, then removed again"
need "the package history shows tree installed" tree_installed
need "the package history shows tree removed" tree_removed
need "tree is no longer installed" '! pkg_installed tree'

task 3 "bash held back from upgrades"
need "bash is held" 'if is_rhel; then dnf versionlock list 2>/dev/null | grep -q "^bash-"; else apt-mark showhold | grep -qx bash; fi'
