# Linux+ 3.5.1: Encrypting data at rest

A LUKS volume on a spare disk, a key file for it, and a file encrypted with
GnuPG.

## Before you start

The lab adds a spare disk, `/dev/loop40` (256 MiB, empty), for you to
encrypt. It's an image file under `/var/lib/le-lab/disks/`, attached again
at every boot. Nothing opens the LUKS volume at boot: after a reboot, open
it with the key file and mount it again before you check.

## Tasks

1. Install `cryptsetup` if it's missing. Format `/dev/loop40` with LUKS
   (choose a passphrase), open it as `lab`, make an ext4 filesystem on it,
   mount it on `/mnt/lab`, and write `hidden` to `/mnt/lab/file.txt`.
2. Look at the LUKS header. Make a 64-byte random key file,
   `/root/lab.key`, with mode 400, and add it to the volume. Then lock the
   volume (unmount and close it), see that the disk can't be mounted
   directly, and open it again with the key file and mount it on
   `/mnt/lab`.
3. In your home directory, encrypt a file `n.txt` with GnuPG, with a
   passphrase (symmetric encryption), to `n.txt.gpg`, and decrypt it
   again.

## Hints

- `cryptsetup luksFormat`, `cryptsetup open`, `mkfs.ext4`, `lsblk`.
- `cryptsetup luksDump`, `dd if=/dev/urandom bs=64 count=1`,
  `cryptsetup luksAddKey DEVICE KEYFILE`; `cryptsetup close`, `blkid`,
  `cryptsetup open --key-file`.
- `gpg --pinentry-mode loopback -c`, `gpg --pinentry-mode loopback -d`.
