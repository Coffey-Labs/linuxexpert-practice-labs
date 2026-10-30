cfg=$(pick /boot/grub2/grub.cfg /boot/grub/grub.cfg)
grub_timeout() {
	(
		. /etc/default/grub
		for f in /etc/default/grub.d/*.cfg; do [ -f "$f" ] && . "$f"; done
		printf '%s' "${GRUB_TIMEOUT:-}"
	) 2>/dev/null
}
# Titles of the menu entries in 40_custom.
custom_titles() { sed -n "s/^[[:space:]]*menuentry[[:space:]]*['\"]\\([^'\"]*\\)['\"].*/\\1/p" /etc/grub.d/40_custom 2>/dev/null; }
new_entry() {
	local t
	while read -r t; do
		[ -n "$t" ] || continue
		grep -qxF "$t" "$LAB_STATE/old-titles" && continue
		grep -qF "menuentry '$t'" "$cfg" || grep -qF "menuentry \"$t\"" "$cfg" || continue
		return 0
	done < <(custom_titles)
	return 1
}

task 1 "GRUB waits 10 seconds"
need "GRUB_TIMEOUT is 10 (after /etc/default/grub.d/ too)" '[ "$(grub_timeout)" = 10 ]'
need "grub.cfg was regenerated with timeout=10" 'grep -Eq "^[[:space:]]*set timeout=10\b" "$cfg"'

task 2 "A kernel option added for one boot" self

task 3 "A custom menu entry with a new title"
need "/etc/grub.d/40_custom has a menuentry" '[ -n "$(custom_titles)" ]'
need "the entry has a linux line" 'grep -Eq "^[[:space:]]*linux(16|efi)?[[:space:]]+/" /etc/grub.d/40_custom'
need "grub.cfg was regenerated with the entry under a new title" new_entry

task 4 "Kernel found from the GRUB command line" self
