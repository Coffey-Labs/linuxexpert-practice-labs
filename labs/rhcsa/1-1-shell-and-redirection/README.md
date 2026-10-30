# RHCSA 1.1: The shell and redirection

Sending output and errors to different files, appending, counting with a
pipe, and writing to a root-owned file with sudo.

## Before you start

The lab removes the files the tasks write in `/tmp`, and any
`test.example.com` line in `/etc/hosts`. Do tasks 1 to 3 as your normal
user, not as root.

## Tasks

1. Run `ls /etc/hostname /nonexistent` so that normal output goes to
   `/tmp/ok.txt` and the error goes to `/tmp/errors.txt`.
2. Append the current date to `/tmp/log.txt` three times without opening
   an editor.
3. Save a list of every file under `/etc` whose name ends in `.conf` to
   `/tmp/confs.txt`, with no error messages in it, and show the number of
   files on the screen.
4. As a normal user, add the line `192.0.2.50 test.example.com` to
   `/etc/hosts` with `sudo` but without opening an editor.

## Hints

- `>` and `2>` send the two streams to different files.
- `>>` appends; `date >>file`.
- `find /etc -name '*.conf'`, `2>/dev/null`, `tee`, `wc -l`.
- `sudo echo ... >>/etc/hosts` fails: the shell opens the file, not sudo.
  `| sudo tee -a`.
