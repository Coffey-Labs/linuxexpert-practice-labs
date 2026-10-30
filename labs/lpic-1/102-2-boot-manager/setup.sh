cfg=$(pick /boot/grub2/grub.cfg /boot/grub/grub.cfg)
[ -f "$cfg" ] || refuse "no $cfg; this lab needs GRUB 2."
[ -f /etc/default/grub ] || refuse "no /etc/default/grub; this lab needs GRUB 2."
if grep -Eq '^[[:space:]]*set timeout=10\b' "$cfg"; then
	refuse "grub.cfg already waits 10 seconds; set GRUB_TIMEOUT to something else first."
fi
tar -C / -cf "$LAB_STATE/grub-config.tar" etc/default/grub $( [ -d /etc/default/grub.d ] && echo etc/default/grub.d ) $( [ -f /etc/grub.d/40_custom ] && echo etc/grub.d/40_custom )
# Titles that exist already, from grub.cfg and BLS entries.
{
	sed -n "s/^[[:space:]]*menuentry[[:space:]]*['\"]\\([^'\"]*\\)['\"].*/\\1/p" "$cfg"
	sed -n 's/^title[[:space:]]*//p' /boot/loader/entries/*.conf 2>/dev/null || true
} >"$LAB_STATE/old-titles"
