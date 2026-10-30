# LPIC-1 107.3: Localization and internationalization

A second locale, what it changes, sort order, and converting a file from
Latin-1 to UTF-8.

## Before you start

The lab writes a short list of words in mixed case to `/root/words.txt`.
The `de_DE.UTF-8` locale must not be installed yet; the lab refuses to start
if it is.

## Tasks

1. Install the `de_DE.UTF-8` locale. Compare `date`, `ls -l` and
   `printf "%'d\n" 1234567` under it and under your normal locale, with
   `LC_ALL=` in front of each. Write what the `printf` prints under
   `de_DE.UTF-8` to `/root/lab-answers/1`.
2. Sort `/root/words.txt` under `LC_ALL=C` into `/root/lab-answers/2-c`, and
   under `LC_ALL=de_DE.UTF-8` into `/root/lab-answers/2-de`, and compare.
3. Make a Latin-1 file with `printf 'caf\xe9\n' > /root/latin1.txt`, check it
   with `file`, look at it with `cat`, and convert it to UTF-8 with `iconv`
   as `/root/utf8.txt`.

## Hints

- RHEL family: `dnf install glibc-langpack-de`. Debian and Ubuntu:
  `locale-gen de_DE.UTF-8` (or uncomment it in `/etc/locale.gen` and run
  `locale-gen`). Check with `locale -a`. Start a new shell after
  installing it.
- `LC_ALL=C sort /root/words.txt > ...`; `diff` the two.
- `iconv -f LATIN1 -t UTF-8`; `file` on both files.
