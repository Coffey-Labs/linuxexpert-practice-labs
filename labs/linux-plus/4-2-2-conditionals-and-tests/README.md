# Linux+ 4.2.2: Conditions and tests

Numeric tests with exit codes, file and string tests, a regular
expression match and a `case` statement.

## Before you start

Work as root, so `~` is `/root`. The lab only checks that
`~/diskcheck.sh` doesn't exist yet. Write answers to the files in
`/root/lab-answers/`.

## Tasks

1. Write the executable script `~/diskcheck.sh`. It takes a limit in
   percent as its first argument (default 80) and reads how full `/` is.
   At or above the limit it prints `ALERT: / is N%` and exits 2; at or
   above the limit minus 10 it prints `warn: / is N%` and exits 1;
   otherwise it prints `ok: / is N%` (exit 0). Run it with no argument and
   with `5`.
2. Loop over `/etc/passwd`, `/etc`, `/nope` and `/bin`, and print for each
   whether it is a `link`, `dir`, `file` or `missing` (as `PATH: TYPE`,
   testing for a link first). Then test an empty variable with `-z`
   (printing `empty`), and compare `10` and `9` as strings with `[[ 10 > 9
   ]] || echo "string compare says 10 < 9"`. Save all of the output in
   `/root/lab-answers/2`.
3. For `10.0.5.21`, `10.0.5` and `web01`, print `X: ipv4` or `X: not ipv4`
   using a regular expression match. Then, for `start`, `stop` and `bogus`,
   use a `case` statement to print `X ok` for start and stop and
   `X unknown` for anything else. Save all of the output in
   `/root/lab-answers/3`.

## Hints

- `df --output=pcent / | tail -1 | tr -dc '0-9'`, `[ "$used" -ge "$limit" ]`,
  `$((limit - 10))`, `exit 2`.
- `[ -L ]`, `[ -d ]`, `[ -f ]`; `{ ...; } > /root/lab-answers/2` saves the
  output of several commands.
- `[[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]`; `case $a in start|stop) ...;;
  *) ...;; esac`.
