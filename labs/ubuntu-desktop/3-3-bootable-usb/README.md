# Ubuntu Desktop 3.3: A bootable USB drive

Checking the signature on Ubuntu's checksum file, seeing a changed copy
fail, and writing an ISO image to a drive with `dd`. A spare disk stands
in for the USB drive.

## Before you start

The lab adds an empty spare disk, `/dev/loop40` (64 MiB), and an empty
folder `/root/usb` to work in. The VM needs to reach
`releases.ubuntu.com`. `xorriso` isn't installed.

## Tasks

1. In `/root/usb`, download `SHA256SUMS` and `SHA256SUMS.gpg` for Ubuntu
   24.04 (`wget https://releases.ubuntu.com/24.04/SHA256SUMS
   https://releases.ubuntu.com/24.04/SHA256SUMS.gpg`) and check the
   signature.
2. Copy `SHA256SUMS` to `/root/usb/SHA256SUMS.copy`, change one character
   of the copy, and check its signature again.
3. Make a small ISO with the volume label `TEST` (install `xorriso`, then
   `xorriso -as mkisofs -V TEST -o test.iso SOMEDIR`) and write it to the
   spare disk `/dev/loop40` with `dd`.

## Hints

- `gpgv --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg
  SHA256SUMS.gpg SHA256SUMS` should print `Good signature`.
- Change a single letter or digit, for example with `sed -i '1s/^./0/'`
  or in an editor; gpgv should now print `BAD signature`.
- `dd if=test.iso of=/dev/loop40 bs=4M conv=fsync`, then `blkid
  /dev/loop40` shows `LABEL="TEST"` and `TYPE="iso9660"`.
