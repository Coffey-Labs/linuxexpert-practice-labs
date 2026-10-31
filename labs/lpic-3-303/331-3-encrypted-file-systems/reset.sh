umount /mnt/secret 2>/dev/null
systemctl stop systemd-cryptsetup@secret.service 2>/dev/null
cryptsetup close secret 2>/dev/null
cp -a "$LAB_STATE/fstab" /etc/fstab 2>/dev/null
if [ -f "$LAB_STATE/crypttab" ]; then cp -a "$LAB_STATE/crypttab" /etc/crypttab; else rm -f /etc/crypttab; fi
rm -f /root/secret.key
rmdir /mnt/secret 2>/dev/null
for u in le-lab-peer-tang.socket; do systemctl disable --now --quiet $u 2>/dev/null; done
systemctl stop 'le-lab-peer-tang@*' 2>/dev/null
rm -f /etc/systemd/system/le-lab-peer-tang.socket /etc/systemd/system/le-lab-peer-tang@.service
systemctl daemon-reload
# crypto's private directory goes with the user; its mount first.
umount /home/crypto/Private 2>/dev/null
# The packages installed since setup started, and only those: not the
# dependencies they leave unneeded that were there before.
pkgs_now() { if is_rhel; then rpm -qa --qf '%{NAME}\n'; else dpkg-query -W -f '${db:Status-Abbrev} ${Package}\n' | awk '$1 == "ii" { print $2 }'; fi | sort -u; }
if [ -s "$LAB_STATE/pkgs-before" ]; then
	new=$(pkgs_now | comm -13 "$LAB_STATE/pkgs-before" - | grep -Ev '^(kernel|linux-)')
	if [ -n "$new" ]; then
		say "Removing the packages installed since the lab started..."
		if is_rhel; then
			dnf -y -q remove --setopt=clean_requirements_on_remove=False $new >/dev/null 2>&1
		else
			DEBIAN_FRONTEND=noninteractive apt-get -y -qq purge $new >/dev/null 2>&1
		fi
	fi
fi
grep -qx tang <<<"${new:-}" && rm -rf $(pick /var/db/tang /var/lib/tang)
true
