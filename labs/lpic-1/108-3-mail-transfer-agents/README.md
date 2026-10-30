# LPIC-1 108.3: Mail transfer agent basics

Local mail with Postfix: sending and reading, an alias for root, a
`.forward` file, and the sendmail command.

## Before you start

The lab creates users `alice` and `bob` (password `Lab-Pass-1`). `alice`
stands in for you: log in as her (or `sudo -iu alice`) to send and read her
mail. No MTA should be installed yet; the lab refuses to start if one is.
Reset removes Postfix and the mail client again.

## Tasks

1. Install Postfix and choose "Local only" (Debian, Ubuntu), or install it
   and start it (RHEL family), so it listens only on this machine. Install
   a `mail` command too.
2. As `alice`, send yourself a message with the subject `Hello me` using
   `mail -s`, and read it with `mail`. Find the mailbox file in
   `/var/mail`.
3. Alias `root` to `alice`, run `newaliases`, send mail to root, and check it
   arrives in `alice`'s mailbox.
4. Create a `~/.forward` for `alice` that sends her mail to `bob`, and test
   it. Then change it to keep a copy for `alice` too, and send her another
   message.
5. Run `mailq` and `sendmail -bp` and compare. Find the sendmail command's
   real program with `readlink -f /usr/sbin/sendmail`, and write that path
   to `/root/lab-answers/5`.

## Hints

- The mail client is `s-nail` on the RHEL family and `mailutils` on Debian
  and Ubuntu. `sudo dpkg-reconfigure postfix` asks the questions again.
  `postconf inet_interfaces`.
- `mail -s "Hello me" alice`; `mail` reads, `q` quits (read messages may
  move to `~/mbox`).
- `/etc/aliases`, `newaliases`; `postmap -q root lmdb:/etc/aliases` (or
  `hash:`) shows what Postfix sees.
- `\alice, bob` in `/home/alice/.forward`, owned by `alice`, mode 644.
