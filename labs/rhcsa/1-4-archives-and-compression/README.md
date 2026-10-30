# RHCSA 1.4: Archives and compression

Creating a compressed archive, extracting one file from it, compressing a
copy while keeping the original, and an archive that keeps owners,
permissions, SELinux contexts and ACLs.

## Before you start

The lab installs `bzip2`, and creates users `dana` and `erik`. A file in
dana's home directory, `shared.txt`, has an ACL that lets erik read it.

## Tasks

1. Create a bzip2-compressed archive of `/etc` named
   `/root/etc-backup.tar.bz2`.
2. Extract only `etc/hostname` from that archive into `/tmp/restore`.
3. Compress a copy of `/var/log/messages` in `/tmp` with gzip, keeping the
   uncompressed copy.
4. As root, archive `/home` with gzip so that owners, permissions, SELinux
   contexts and ACLs are kept, to `/root/home.tgz`.

## Hints

- `tar -cjf`; `file`, `tar -tf`.
- `tar -xf ARCHIVE -C DIR MEMBER`; the directory must exist first.
- `gzip -k`, or `gzip -c FILE >FILE.gz`.
- `tar --selinux --acls --xattrs -czf`; `tar -tvzf`.
