# Linux+ 1.5.4: Text editors

Vim's basic moves on a real file, a change in nano, and your preferred
editor for programs such as `crontab -e`.

## Before you start

The lab removes `/tmp/s.conf` if it's there, and notes the startup files
task 4 may change so that reset can put them back. Ubuntu empties `/tmp` at
boot, so do task 2 without a reboot.

On the RHEL family, install full Vim and nano first. A minimal or cloud
install has only `vi`:

```
dnf install -y vim-enhanced nano
```

Reset removes them again if they weren't installed when the lab started.

## Tasks

1. Run `vimtutor` and work through lessons 1 and 2 (about 15 minutes). Not
   graded.
2. Copy `/etc/ssh/sshd_config` to `/tmp/s.conf` and open it in Vim. Turn on
   line numbers, jump to the first line with `Port`, copy it, paste it
   below, and change the copy to `Port 2222`. Replace every `yes` with
   `YES`, undo that, and save and quit.
3. Make the same kind of change to `/tmp/s.conf` in nano, then quit without
   saving. Not graded.
4. Set your preferred editor for good (with `EDITOR` or `VISUAL` in a shell
   startup file, or with `select-editor` on Ubuntu), and try it with
   `crontab -e`; quit without saving.

## Hints

- `:set number`, `/Port`, `yy`, `p`, `cw` or `C`, `:%s/yes/YES/g`, `u`,
  `:wq`.
- In nano, `Ctrl+x` then `n` quits without saving.
- `export EDITOR=nano` in `~/.bashrc`; `crontab -e` reads `VISUAL`, then
  `EDITOR`.
