D=/dev/loop40
# symmetric FILE: FILE starts with a GnuPG passphrase (symmetric key) packet.
symmetric() {
	local g; g=$(mktemp -d)
	gpg --homedir "$g" --batch --list-packets --pinentry-mode loopback --passphrase le-not-it "$1" 2>/dev/null | grep -q '^:symkey enc packet:'
	local r=$?; rm -rf "$g"; return $r
}

task 1 "LUKS on /dev/loop40, open as lab, ext4 mounted on /mnt/lab"
need "/dev/loop40 is a LUKS volume" '[ "$(blkid -s TYPE -o value $D)" = crypto_LUKS ]'
need "it's open as /dev/mapper/lab" 'cryptsetup status lab | grep -Eq "device:[[:space:]]+$D$"'
need "/mnt/lab is mounted from /dev/mapper/lab, ext4" '[ "$(findmnt -n -o SOURCE,FSTYPE /mnt/lab | tr -s " ")" = "/dev/mapper/lab ext4" ]'
need "/mnt/lab/file.txt says hidden" 'grep -qx hidden /mnt/lab/file.txt'

task 2 "A key file opens the volume too"
need "/root/lab.key is 64 bytes, mode 400" '[ "$(stat -c %s:%a /root/lab.key)" = 64:400 ]'
need "the key file opens /dev/loop40" 'cryptsetup open --test-passphrase --key-file /root/lab.key $D'
need "two key slots are in use" '[ "$(cryptsetup luksDump $D | grep -cE "^[[:space:]]+[0-9]+: luks2")" -ge 2 ] || [ "$(cryptsetup luksDump $D | grep -c "Key Slot [0-9]: ENABLED")" -ge 2 ]'

task 3 "n.txt encrypted with a passphrase"
need "n.txt.gpg is in your home directory" 'ls /root/n.txt.gpg /home/*/n.txt.gpg 2>/dev/null | grep -q .'
need "it's encrypted with a passphrase" 'for f in /root/n.txt.gpg /home/*/n.txt.gpg; do [ -f "$f" ] && symmetric "$f" && exit 0; done; exit 1'
