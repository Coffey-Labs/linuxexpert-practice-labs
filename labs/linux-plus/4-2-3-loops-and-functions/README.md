# Linux+ 4.2.3: Loops and functions

Reading a file line by line into fields, the pipe subshell trap, and a
script with functions and local variables.

## Before you start

Work as root, so `~` is `/root`. The lab creates user `alice`, so there is
at least one normal account to find, and checks that `~/hosts.sh` doesn't
exist yet. Write answers to the files in `/root/lab-answers/`.

## Tasks

1. With a `while IFS=: read -r ...` loop over `/etc/passwd`, print
   `USER -> SHELL` for every account with a UID from 1000 up to (not
   including) 65534. Save the output in `/root/lab-answers/1`.
2. Count the entries of `ls /etc` twice into a variable `c`: once in a
   `while read` loop at the end of a pipe, printing `pipe: $c`, and once
   with the loop reading from process substitution, printing
   `process substitution: $c`. Save both lines in `/root/lab-answers/2`,
   and work out why the first count is 0.
3. Write `~/hosts.sh`: it sets `msg="global"`, has a function `check` with
   a local `msg="checking HOST"` that it prints before pinging the host once
   (one-second timeout), loops over its arguments printing `  up` or
   `  down` after each check, and ends by printing `msg is still: $msg`. Run
   it with `localhost 192.0.2.1`.

## Hints

- `while IFS=: read -r user _ uid _ _ home shell; do ...; done < /etc/passwd`.
- `ls /etc | while read -r x; do c=$((c+1)); done` runs the loop in a
  subshell; `done < <(ls /etc)` doesn't.
- `check() { local msg="checking $1"; ...; }`, `for h in "$@"`,
  `check "$h" && echo "  up" || echo "  down"`.
- The chapter's step 2 (`until` and a second terminal) isn't graded; try
  it anyway.
