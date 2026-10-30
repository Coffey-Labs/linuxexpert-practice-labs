# Linux+ 4.4.1: Git basics

Configuring Git, a first repository and commit, ignoring files, staging
and diffs, and a branch.

## Before you start

Work as root, so `~` is `/root`. The lab only checks that `~/repo` doesn't
exist yet, and notes whether you already have a `~/.gitconfig` (reset
removes one the lab didn't find).

## Tasks

1. Install Git, set your name and email globally and make `main` the
   default branch name. Create the repository `~/repo`, and commit an
   executable script `hello.sh` that prints `hello` with the message
   `Add hello script`.
2. Make Git ignore `*.log` files (create `run.log` to see it), change the
   greeting in `hello.sh` to `hello, world`, look at the unstaged and staged
   diffs, and commit everything with the message `Greet the world, ignore
   logs`.
3. Create a branch `feature`, append a `date` line to `hello.sh` there and
   commit it as `Print the date`. Back on `main`, `hello.sh` has no date
   line; compare the branches.

## Hints

- `git config --global user.name`, `user.email`, `init.defaultBranch`;
  `git init`, `git status`, `git add`, `git commit -m`.
- `.gitignore`, `git status --short`, `git diff`, `git add -A`,
  `git diff --staged`, `git log --oneline`.
- `git checkout -b feature` (or `git switch -c`), `git commit -am`,
  `git log --oneline --graph --all`, `git diff main..feature`.
