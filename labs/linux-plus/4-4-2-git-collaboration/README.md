# Linux+ 4.4.2: Working with remotes and history

A bare "server" repository, pushing, cloning, fetching and pulling, a
squash merge, an annotated tag, the stash, and undoing commits.

## Before you start

Work as root, so `~` is `/root`. The lab installs Git and creates `~/repo`
as chapter 4.4.1 leaves it: `main` with the commits `Add hello script`
and `Greet the world, ignore logs`, and a branch `feature` with the
commit `Print the date`. If you have no Git identity or default branch
name yet, it sets them in `~/.gitconfig` as chapter 4.4.1 does (reset
removes the file again). It checks that `~/remote.git` and
`~/repo2` don't exist yet. Don't run the chapter's clean-up step:
`le-lab reset` does it.

## Tasks

1. Create the bare repository `~/remote.git`, add it to `~/repo` as
   `origin`, push `main` and `feature` to it (setting the upstream), and
   clone it to `~/repo2`.
2. In `~/repo2`, add a file `README` containing `Lab scripts`, commit it
   as `Add a README` and push it. In `~/repo`, fetch, see the new commit
   with `git log main..origin/main`, and pull it.
3. In `~/repo` on `main`, squash-merge `feature` and commit it as `Print
   the date (squashed)`. Tag that commit as `v1.0` with the message `First
   release`. Then append `wip` to `hello.sh`, stash the change, look at the
   status, and pop the stash again.
4. Commit everything as `Oops`, then undo that commit with a soft reset
   (keeping the change staged), unstage it and throw it away. Finally undo
   the squashed commit without rewriting history, with `git revert`.

## Hints

- `git init --bare`, `git remote add origin`, `git push -u origin main
  feature`, `git clone`.
- `git push`, `git fetch`, `git log --oneline main..origin/main`,
  `git pull`.
- `git merge --squash feature`, `git commit -m`, `git tag -a v1.0 -m`,
  `git log --oneline --decorate`, `git stash`, `git stash pop`.
- `git commit -am`, `git reset --soft HEAD~1`, `git restore --staged`,
  `git restore`, `git revert --no-edit HEAD`.
