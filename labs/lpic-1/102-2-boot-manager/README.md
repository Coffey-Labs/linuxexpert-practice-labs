# LPIC-1 102.2: Installing a boot manager

Changing GRUB's settings, regenerating `grub.cfg`, adding a custom menu
entry, and using the GRUB menu and command line.

## Before you start

Take a snapshot first: this lab changes the boot loader's configuration.
The lab saves `/etc/default/grub`, `/etc/default/grub.d/` and
`/etc/grub.d/40_custom`; reset puts them back and regenerates `grub.cfg`.
To see the GRUB menu you need the VM's console, not SSH.

## Tasks

1. Change `GRUB_TIMEOUT` to 10, regenerate `grub.cfg`, and reboot to see
   it.
2. Add a kernel option at the menu with **e** for one boot, then check
   `/proc/cmdline`. Check it yourself: the option shows in `/proc/cmdline`
   for that boot only.
3. Copy an entry from `grub.cfg` into `/etc/grub.d/40_custom`, change its
   title, regenerate, and boot it. On AlmaLinux, `grub.cfg` has no entries
   to copy: write the entry from one of the files in
   `/boot/loader/entries/` instead.
4. Open the GRUB command line with **c** and find your kernel with `ls`.
   Check it yourself: `ls (hd0,gpt3)/` or similar lists a `vmlinuz` file.

## Hints

- `/etc/default/grub`; on Ubuntu cloud images a file in
  `/etc/default/grub.d/` sets `GRUB_TIMEOUT` again, after it, and
  `GRUB_TIMEOUT_STYLE=hidden` hides the menu.
- `grub2-mkconfig -o /boot/grub2/grub.cfg` on the RHEL family,
  `update-grub` on Debian and Ubuntu.
- A `menuentry 'Title' { ... }` block keeps its `linux` and `initrd`
  lines; on AlmaLinux they come from the `linux`, `options` and `initrd`
  lines of a BLS entry.
- `grub2-reboot` or `grub-reboot` with the title boots an entry once.
