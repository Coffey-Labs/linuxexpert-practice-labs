# RHCSA 1.3: SSH and switching users

Running one command on another machine over SSH, switching users with a
full login environment, running a command as another user, and logging in
on a text console.

## Before you start

The peer, at `10.99.0.2` (name `peer`), stands in for the second VM. It
runs its own sshd. It shares this VM's files and users, so it has the same
host name, but not its network: logins to it come from `10.99.0.1`. The
lab creates user `tester` (password `Lab-Pass-1`) to log in there with.
Write the results of tasks 1 and 3 to the files named there, so they can
be checked.

## Tasks

1. Run `hostname` on the peer over SSH as `tester`, without staying logged
   in, and save the name it prints to `/root/lab-answers/1`.
2. Create a user `alice` with a password, then switch to her with a full
   login environment from your normal user.
3. As root, run `id` as alice without switching to her and without a
   password, and save its output to `/root/lab-answers/3`.
4. Log in on the second text console of this VM (`tty2`) as alice, and
   stay logged in there while you check.

## Hints

- `ssh USER@HOST COMMAND`; `sudo tee` or `| sudo tee /root/lab-answers/1`.
- `useradd`, `passwd`; `su - alice`, then `pwd` and `whoami`.
- `sudo -u alice id`, `runuser -u alice -- id`.
- The VM's console: Ctrl+Alt+F2 (in a VM window, send the key combination
  from its menu), or `chvt 2`. `who` lists the logins.
