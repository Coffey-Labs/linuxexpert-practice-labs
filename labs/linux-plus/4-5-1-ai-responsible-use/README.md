# Linux+ 4.5.1: Using AI responsibly

The review habit, without any AI tool: checking a generated script with
ShellCheck, and rewriting it so it fails safely.

## Before you start

Work as root, so `~` is `/root`. The VM needs internet access to install
ShellCheck (from EPEL on RHEL relatives). The lab only checks that
`~/ai-cleanup.sh` and `~/cleanup.sh` don't exist yet. Write answers to the
files in `/root/lab-answers/`. Don't run the chapter's clean-up line: the
lab grades `~/cleanup.sh`, and `le-lab reset` removes the files.

## Tasks

1. Save the chapter's "AI-written" `~/ai-cleanup.sh`, and find its problems
   before running anything. Install ShellCheck, run it on the script, and
   save its report in `/root/lab-answers/1`.
2. Write the safer `~/cleanup.sh`: with `set -euo pipefail`, it takes a
   directory and a number of days as required arguments (with a usage
   message), refuses a number of days that isn't a number, and deletes
   only `*.tar.gz` files directly in that directory that are older than
   that many days, printing each one. Test it on throwaway files in
   `/tmp/bk`, and make sure ShellCheck has nothing to say about it.

## Hints

- `dnf install ShellCheck` (EPEL) or `apt install shellcheck`;
  `shellcheck ~/ai-cleanup.sh > /root/lab-answers/1`.
- `${1:?usage: cleanup.sh DIR DAYS}`, `[[ $days =~ ^[0-9]+$ ]]`,
  `find "$dir" -maxdepth 1 -type f -name '*.tar.gz' -mtime +"$days" -print
  -delete`; `touch -d '20 days ago'`.
- The chapter's step 3 (writing a prompt) isn't graded.
