# LPIC-1 108.4: Printers and printing

CUPS with a PDF printer: printing, holding and cancelling jobs, and debug
logging.

## Before you start

The lab creates user `alice` (password `Lab-Pass-1`) and installs
`ipptool`, which the check uses to read CUPS's job history. CUPS itself isn't installed yet: that's task 1. Reset removes CUPS
and the PDF printer again.

## Tasks

1. Install `cups` and a PDF printer (`printer-driver-cups-pdf` on Debian and
   Ubuntu; `cups-pdf`, from EPEL, on the RHEL family), and find the printer
   with `lpstat -p`. As `alice`, print a text file to it; find the PDF it
   makes, and write the PDF's full path to `/root/lab-answers/1`.
2. Disable the printer with a reason, print two files, list them with `lpq`
   and `lpstat -o`, remove one with `lprm` and the other with `cancel`, then
   enable it again. Also reject jobs on the printer and try to print; read
   the message, then accept jobs again.
3. Turn on CUPS's debug logging, print a file, and read what `error_log`
   (or `journalctl -u cups`) shows. Leave debug logging on.

## Hints

- `lpstat -p -v`; `lp -d PRINTER file`. The PDF lands in `~/PDF` on Debian
  and Ubuntu; on the RHEL family it goes to `~/Desktop`, or the home
  directory when there's no Desktop. Root's own jobs may fail there. If
  `lpstat -p` shows no printer, add one: `lpinfo -m | grep -i pdf`, then
  `lpadmin -p PDF -E -v cups-pdf:/ -m ...`.
- `cupsdisable -r "reason"`, `cupsenable`, `cupsreject -r`, `cupsaccept`;
  `lpstat -p -l`. On Ubuntu, `lpq` and `lprm` are in the `cups-bsd`
  package.
- `cupsctl --debug-logging`, `cupsctl`; `/var/log/cups/error_log`.
