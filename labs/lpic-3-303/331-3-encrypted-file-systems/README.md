# LPIC-3 331.3: Encrypted file systems

LUKS on a spare disk: key slots, a key file, the LUKS1 to LUKS2
conversion, unlocking at boot from crypttab, network-bound unlocking with
Clevis and Tang, and an eCryptfs private directory.

## Before you start

The lab adds a spare disk, `/dev/loop40` (512 MiB, empty). It's an image
file under `/var/lib/le-lab/disks/`, attached again at every boot, before
crypttab is read.

The peer, at `10.99.0.2` (name `peer`), stands in for the other VM and
already runs a Tang server on its port 80 (`le-lab-peer-tang.socket`):
`curl http://10.99.0.2/adv` shows its advertisement.

On Ubuntu, the lab also creates the user `crypto` (password `Lab-Pass-1`)
for task 5.

## Tasks

1. Install `cryptsetup` if it's missing. Format `/dev/loop40` as LUKS1
   with the passphrase `lab-pass-one`, open it as `secret`, make an ext4
   file system on it, mount it on `/mnt/secret`, and write `top secret` to
   `/mnt/secret/note.txt`.
2. Add a 64-byte random key file, `/root/secret.key` (mode 400), to a
   second key slot. Then close the volume and convert it to LUKS2.
3. Unlock and mount the volume at boot the way the system does it: a
   crypttab entry `secret` that names the volume by UUID and uses the key
   file, and an fstab entry that mounts `/dev/mapper/secret` on
   `/mnt/secret`, both with `nofail`. Start it through systemd and check
   that `note.txt` is there.
4. Install Clevis with its LUKS support, and bind the volume to the Tang
   server at `http://10.99.0.2`, so that `clevis luks unlock` opens it with
   no passphrase while Tang is reachable. The passphrase must still work.
5. Ubuntu: set up an eCryptfs private directory for `crypto`, wrapped with
   their login password `Lab-Pass-1`, that doesn't mount automatically at
   login. Mount it as `crypto`, write `private data` to
   `~/Private/diary.txt`, and unmount it again.

## Hints

- `cryptsetup luksFormat --type luks1`, `cryptsetup open`,
  `cryptsetup status`; `echo -n 'lab-pass-one' | cryptsetup ... -` reads
  the passphrase from standard input.
- `dd if=/dev/urandom bs=64 count=1`, `cryptsetup luksAddKey`,
  `cryptsetup luksDump`, `cryptsetup convert --type luks2` (the volume
  must be closed).
- `cryptsetup luksUUID`; a crypttab line is name, device, key file,
  options. `systemctl daemon-reload`,
  `systemctl start systemd-cryptsetup@secret.service`, `mount /mnt/secret`.
- `clevis luks bind -d DEVICE tang '{"url":"http://10.99.0.2"}'`,
  `clevis luks list`; `clevis luks unlock -d DEVICE -n NAME` needs the
  volume closed first.
- `ecryptfs-utils`, `modprobe ecryptfs`;
  `su - crypto -c "ecryptfs-setup-private --nopwcheck --noautomount ..."`.
  To mount without a terminal, `ecryptfs-insert-wrapped-passphrase-into-keyring
  ~/.ecryptfs/wrapped-passphrase -` with the login password on standard
  input, then `/sbin/mount.ecryptfs_private`; `/sbin/umount.ecryptfs_private`.
