# LFCS 4.1: Basic Git operations

Cloning, branching, merging, undoing a commit, ignoring files and tagging,
against a shared repository on the same VM.

## Before you start

The lab creates a bare repository at `/srv/git/app.git` with some history:
`app.conf`, a `README.md`, a committed `debug.log`, and a branch
`feature/workers`. Work as root, and clone it to `/root/app`; the lab grades
that clone and the repository in `/srv/git`. Set your name and email in Git
first.

## Tasks

1. Clone `/srv/git/app.git` to `/root/app`, create a branch `feature/motd`,
   commit a new file on it, and push the branch.
2. On `main`, change the `workers` line in `app.conf` to a different value
   than `feature/workers` uses, commit it, then merge `feature/workers` into
   `main` and resolve the conflict.
3. Find the commit that last changed the `timeout` line in `app.conf`, and
   undo that commit on `main` without rewriting history.
4. Make Git ignore all `.log` files, stop tracking `debug.log` without
   deleting it from disk, and commit the change on `main`.
5. Tag the current commit of `main` as `v1.0` with a message, and push the
   tag.

## Hints

- `git config --global user.name`, `git clone`, `git switch -c`,
  `git push -u origin`, `git ls-remote origin`.
- `git merge`, then edit the file, `git add` and `git commit`;
  `git log --oneline --graph`.
- `git blame app.conf`, `git revert`.
- `.gitignore`, `git rm --cached`.
- `git tag -a -m`, `git push origin v1.0`, `git ls-remote --tags origin`.
