# LPIC-1 103.2: Processing text with filters

Counting with `cut`, `sort` and `uniq`, spotting Windows line endings,
splitting and joining files, and following a log.

## Before you start

The lab creates `/root/filters/` with three text files, `report1.txt`,
`report2.txt` and `report3.txt`; one of them has Windows line endings.
Work as root (`sudo -i`), and write answers to the files in
`/root/lab-answers/`. Where the journal is kept only in memory (no
`/var/log/journal`), a reboot loses task 5's message, so check before
you reboot.

## Tasks

1. Make `/root/filters/fruit.txt` with the five lines from the chapter:

   ```
   apple 3
   banana 12
   cherry 7
   apple 5
   banana 1
   ```

   Count how many lines mention each fruit with `cut`, `sort` and
   `uniq -c`, and write the output to `/root/lab-answers/1`.
2. Count the accounts using each login shell in `/etc/passwd`, most common
   first, and write the output to `/root/lab-answers/2`.
3. Use `od -c` to find out which of the three report files uses Windows
   line endings (`\r \n`), and write its name to `/root/lab-answers/3`.
4. Split a large file from `/var/log` into 100-line pieces in
   `/root/filters/split/`, join them back with `cat` into
   `/root/filters/joined.log`, and prove the result is identical with
   `sha256sum`.
5. Follow `/var/log/syslog` or `/var/log/messages` with `tail -f` in one
   terminal while running `logger hello` in another. If neither file
   exists, your system logs only to the journal: use `journalctl -f`
   instead.

## Hints

- `cut -d' ' -f1 FILE | sort | uniq -c`.
- `cut -d: -f7`, then `sort | uniq -c | sort -rn`.
- `od -c FILE | head`; `file` says "with CRLF line terminators" too.
- `split -l 100 FILE /root/filters/split/part-`, `cat .../part-* >
  ...`, `sha256sum`. Pick a file that doesn't change while you work, such
  as `cloud-init.log` or an older rotated log.
- `logger hello`; `journalctl -f` or `journalctl -t USER`.
