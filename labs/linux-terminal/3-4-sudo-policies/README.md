# Using Linux Terminal 3.4: sudo policies

A narrow passwordless rule in a drop-in file, an administrator by group
membership, and the file names sudo skips.

## Before you start

Work as root (`sudo -i`), and write answers to the files in
`/root/lab-answers/`. The lab creates users `alice` and `bob` (password
`Lab-Pass-1`). Edit sudoers files only with `visudo` (`visudo -f
/etc/sudoers.d/NAME`): it refuses to save a file with a mistake in it, and
a broken sudoers file stops sudo working for everyone. Keep the root shell
open while you work. The lab saves `/etc/sudoers` and puts it back on
reset, and removes the files you add to `/etc/sudoers.d`.

## Tasks

1. Let `alice` restart and check the status of the ssh service as root,
   with no password, and nothing else. Use a drop-in file. `visudo -c`
   reports every file "parsed OK"; as alice, `sudo systemctl restart ssh`
   works, and `sudo id` asks for her password and then says she isn't
   allowed.
2. Make `bob` an administrator who can run anything with his password,
   without editing any sudoers file.
3. Name your drop-in `alice.conf` instead, and see what `sudo -l -U alice`
   says. Write that to `/root/lab-answers/3`, then rename the file back.

## Hints

- `alice ALL=(root) NOPASSWD: /usr/bin/systemctl restart ssh,
  /usr/bin/systemctl status ssh`; `sudo -l -U alice`; test as alice with
  `su - alice`.
- Ubuntu's `/etc/sudoers` gives group `sudo` everything; `usermod -aG`.
- `@includedir /etc/sudoers.d` skips names with a dot or ending in `~`.
