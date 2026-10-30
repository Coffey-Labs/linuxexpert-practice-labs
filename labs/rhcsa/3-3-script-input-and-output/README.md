# RHCSA 3.3: Script input and command output

Arguments, usage messages and exit codes, looping over all arguments,
command substitution in file names, and adding up command output.

## Before you start

The lab creates user `student`. Write each script where its task says
and make it executable; the checks run them.

## Tasks

1. Write `/usr/local/bin/count-files` that takes a directory and prints
   how many entries it holds, including hidden ones. With no argument or
   a non-directory, it prints `usage: count-files DIRECTORY` to standard
   error and exits 1. (Write the name literally: run from `PATH`, `$0` is
   `/usr/local/bin/count-files`.)
2. Write `/root/homes.sh` that takes any number of user names and prints
   each user's home directory, or `NAME: no such user`.
   `/root/homes.sh root nosuchuser student` prints `/root`, the error line
   and `/home/student`.
3. Write `/root/df-today.sh` that saves the output of `df -h /` to a file
   named after today's date, such as `/root/df-2026-10-20.txt`, and run
   it.
4. Write `/root/sumlines.sh` that prints the sum of the line counts of
   every file given as an argument (just the number).

## Hints

- `$#`, `[ -d "$1" ]`, `echo ... >&2`, `exit 1`; `ls -A "$1" | wc -l`.
- `for u in "$@"`; `getent passwd "$u" | cut -d: -f6`.
- `$(date +%F)`.
- `wc -l <"$f"`, `$((total + n))`.
