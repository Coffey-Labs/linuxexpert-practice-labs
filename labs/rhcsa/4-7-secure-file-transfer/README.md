# RHCSA 4.7: Secure file transfer

Copying files to and from another machine with scp, rsync and sftp,
keeping permissions and times.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for the other VM. It
runs its own sshd, and shares this VM's files and users, so your account
there needs to be a different user to keep the copies apart: you are
`alice` here, and `bob` on the peer.

The lab creates users `alice` and `bob` (password `Lab-Pass-1`). alice
has an SSH key that logs in as `bob@peer`, a directory `~/proj` with a
few files (one of them mode 640, all dated January 2026), and a file
`~/report.txt`. Do the tasks as alice: `sudo su - alice`.

## Tasks

1. Copy the directory `~/proj` to bob's home directory on the peer
   (`bob@peer:`), keeping permissions and modification times.
2. Fetch `/etc/os-release` from the peer into a local directory `~/got`.
3. Copy `~/proj/` to `backup/` in bob's home on the peer with rsync,
   change one file in `~/proj`, and copy again. The second run lists only
   the changed file.
4. Use sftp to upload `~/report.txt` to `/tmp` on the peer, and download
   it again as `~/report-back.txt`.

## Hints

- `scp -rp proj bob@peer:`; `ssh bob@peer ls -l proj`.
- `scp bob@peer:/etc/os-release ~/got/`; the directory must exist.
- `rsync -av proj/ bob@peer:backup/`; the trailing slash copies the
  contents.
- `sftp bob@peer`, then `put`, `get REMOTE LOCAL`, `bye`.
