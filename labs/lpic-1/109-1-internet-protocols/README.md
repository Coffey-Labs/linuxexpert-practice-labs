# LPIC-1 109.1: Internet protocol fundamentals

Subnets worked out by hand, well-known ports, and IPv6 address notation.
Nothing here changes the VM: the answers go in files.

## Before you start

The lab sets up nothing. Write each answer in `/root/lab-answers/`.

## Tasks

1. Work out the network, broadcast, first and last host for
   `10.1.2.3/23`, `172.16.40.200/27` and `192.168.5.5/30` on paper, then
   check with `ipcalc` (install the `ipcalc` package if needed). Write one
   line per network to `/root/lab-answers/1`, in that order, each with four
   addresses separated by spaces: network, broadcast, first host, last host.
2. Look up the service names of ten ports from the chapter's table in
   `/etc/services`. Write ten lines to `/root/lab-answers/2`, each a port
   number and its name as `/etc/services` gives it, such as `22 ssh`.
3. Write `fe80:0000:0000:0000:0204:61ff:fe9d:f156` in its shortest form as
   the first line of `/root/lab-answers/3`, and `2001:db8:a::1` expanded to
   all eight groups of four digits as the second.

## Hints

- A `/23` covers two `/24`s; a `/27` is a block of 32 addresses; a `/30` a
  block of 4.
- `grep -w 53 /etc/services`, `getent services 53`.
- Leading zeros in a group can go; one run of zero groups becomes `::`.
