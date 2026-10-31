D=/dev/loop40
UUID=$(blkid -s UUID -o value $D 2>/dev/null)
# crypttab_secret FIELD: a field of the crypttab entry "secret".
crypttab_secret() { awk -v f="$1" '$1 == "secret" { print $f; exit }' /etc/crypttab 2>/dev/null; }

task 1 "LUKS on /dev/loop40, open as secret, ext4 on /mnt/secret with note.txt"
need "/dev/loop40 is a LUKS volume" '[ "$(blkid -s TYPE -o value $D)" = crypto_LUKS ]'
need "the passphrase lab-pass-one opens it" 'printf %s lab-pass-one | cryptsetup open --test-passphrase $D -'
need "it's open as /dev/mapper/secret" 'cryptsetup status secret | grep -Eq "device:[[:space:]]+$D$"'
need "/mnt/secret is mounted from /dev/mapper/secret, ext4" '[ "$(findmnt -n -o SOURCE,FSTYPE /mnt/secret | tr -s " ")" = "/dev/mapper/secret ext4" ]'
need "/mnt/secret/note.txt says top secret" 'grep -qx "top secret" /mnt/secret/note.txt'

task 2 "Key file /root/secret.key in a second slot, header converted to LUKS2"
need "/root/secret.key is 64 bytes, mode 400" '[ "$(stat -c %s:%a /root/secret.key)" = 64:400 ]'
need "the key file opens the volume" 'cryptsetup open --test-passphrase --key-file /root/secret.key $D'
need "the header is LUKS2" 'cryptsetup luksDump $D | grep -Eq "^Version:[[:space:]]+2$"'
need "a key slot still uses PBKDF2 (it was converted from LUKS1)" 'cryptsetup luksDump $D | grep -Eq "^[[:space:]]+PBKDF:[[:space:]]+pbkdf2"'

task 3 "crypttab and fstab unlock and mount it at boot"
need "/etc/crypttab has an entry secret for the volume's UUID" '[ -n "$UUID" ] && [ "$(crypttab_secret 2)" = "UUID=$UUID" ]'
need "the entry uses /root/secret.key" '[ "$(crypttab_secret 3)" = /root/secret.key ]'
need "the entry has nofail" 'crypttab_secret 4 | tr , "\n" | grep -qx nofail'
need "/etc/fstab mounts /dev/mapper/secret on /mnt/secret, with nofail" 'awk "\$1 == \"/dev/mapper/secret\" && \$2 == \"/mnt/secret\" && \$4 ~ /(^|,)nofail(,|$)/ { f = 1 } END { exit !f }" /etc/fstab'
need "systemd-cryptsetup@secret.service is active" active systemd-cryptsetup@secret.service
need "/mnt/secret is mounted with note.txt" 'grep -qx "top secret" /mnt/secret/note.txt'

task 4 "Bound to Tang at http://10.99.0.2 with Clevis"
need "clevis luks list shows a tang binding to 10.99.0.2" 'clevis luks list -d $D 2>/dev/null | grep -q "tang.*10\.99\.0\.2"'
need "Clevis gets a working key from Tang" 'for s in $(clevis luks list -d $D 2>/dev/null | grep tang | cut -d: -f1); do timeout 15 clevis luks pass -d $D -s $s 2>/dev/null | cryptsetup open --test-passphrase --key-file - $D && exit 0; done; exit 1'
need "the passphrase lab-pass-one still works" 'printf %s lab-pass-one | cryptsetup open --test-passphrase $D -'

task 5 "eCryptfs private directory for crypto" debian
need "crypto has a wrapped passphrase" '[ -s /home/crypto/.ecryptfs/wrapped-passphrase ]'
need "it doesn't mount automatically at login" '[ ! -e /home/crypto/.ecryptfs/auto-mount ]'
need "~/.Private holds an encrypted file name" 'ls /home/crypto/.Private | grep -q "^ECRYPTFS_FNEK_ENCRYPTED\."'
need "nothing in ~/.Private is stored in the clear" '! grep -rqs "private data" /home/crypto/.Private'
need "mounted with Lab-Pass-1, ~/Private/diary.txt says private data" 'modprobe ecryptfs; if grep -q " /home/crypto/Private ecryptfs " /proc/mounts; then grep -qx "private data" /home/crypto/Private/diary.txt; else su - crypto -c "printf %s Lab-Pass-1 | ecryptfs-insert-wrapped-passphrase-into-keyring ~/.ecryptfs/wrapped-passphrase - && /sbin/mount.ecryptfs_private && grep -qx \"private data\" ~/Private/diary.txt; r=\$?; /sbin/umount.ecryptfs_private; exit \$r"; fi'
