# LPIC-1 103.1: Working on the command line

Quoting, exported variables, running your own scripts, builtins and
programs, and searching the manual.

## Before you start

The lab installs `man-db` and builds the manual's search index if needed.
Work as root (`sudo -i`) unless a task says otherwise, and write answers
to the files in `/root/lab-answers/`.

## Tasks

1. Predict what each of these prints, then check:
   `echo '$HOME'`, `echo "$HOME"`, `echo \$HOME`, `echo "It's $USER"`.
   Write the four outputs, as root, one per line in that order, to
   `/root/lab-answers/1`.
2. Set a variable, show that `bash -c 'echo $var'` can't see it, export
   it, and try again. Check it yourself: the second try prints the value.
3. Write a two-line script, `hello.sh`, in your home directory, make it
   executable with `chmod +x`, and run it with `./hello.sh`. Then try
   running it by name alone, and write why that fails to
   `/root/lab-answers/3`.
4. Run `type` on `cd`, `ls`, `echo` and `ssh`, and compare with `which`.
   Write the ones that are shell builtins to `/root/lab-answers/4`.
5. Find the man page for the `crontab` file format (not the command) using
   `man -k`, and write how you'd open it (such as `man 1 ls`) to
   `/root/lab-answers/5`.

## Hints

- Single quotes keep everything literal, double quotes expand `$`, and
  `\` protects one character.
- `export var`, `env | grep var`.
- `#!/bin/bash` on line 1; `echo $PATH`.
- `type -a`; `which` only searches `PATH`.
- `man -k crontab` (or `apropos`); the number in brackets is the section.
