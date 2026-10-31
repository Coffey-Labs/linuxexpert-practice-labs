# LFCA 5.2: Git concepts

A first repository, a merge conflict, a bare repository as a remote, and
undoing a commit with `git revert`.

## Before you start

Work as root (`sudo -i`), so `~` is `/root`. The lab only checks that
`~/project`, `~/app.git` and `~/app-copy` don't exist yet, and notes
whether you already have a `~/.gitconfig` and Git (reset removes the ones
the lab didn't find).

## Tasks

1. Install Git, set your name and email (and `init.defaultBranch main`, as
   the chapter shows), create the repository `~/project`, make three
   commits on `main`, and read the log with `git log --oneline`.
2. Make a branch, change the same line on it and on `main`, merge the
   branch into `main`, and resolve the conflict.
3. Create a bare repository with `git init --bare -b main ~/app.git` to
   act as a remote, and push `~/project`'s `main` to it. Clone it into
   `~/app-copy`, commit a change there and push it, then `pull` the change
   back into `~/project`.
4. In `~/project`, commit a bad change, then undo it with `git revert`, and
   read the log.

## Hints

- `git config --global user.name`, `user.email`, `init.defaultBranch`;
  `git init ~/project`, `git add`, `git commit -m`.
- `git switch -c NAME`, `git switch main`, `git merge NAME`; edit the file
  to remove the `<<<<<<<`, `=======` and `>>>>>>>` lines, then `git add`
  and `git commit`.
- `-b main` names the bare repository's default branch. Without it or
  `init.defaultBranch`, it's `master`, and the clone warns "remote HEAD
  refers to nonexistent ref" and comes out empty.
- `git remote add origin ~/app.git`, `git push -u origin main`,
  `git clone ~/app.git ~/app-copy`, `git push`, `git pull`.
- `git revert HEAD`, `git log --oneline`.
