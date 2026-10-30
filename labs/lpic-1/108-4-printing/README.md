# LPIC-1 108.4: Printers and printing

CUPS with a PDF printer: printing, holding and canceling jobs, and debug
logging.

## Before you start

The lab creates user `alice` (password `Lab-Pass-1`) and installs
`ipptool`, which the check uses to read CUPS's job history. CUPS itself
isn't installed yet: that's task 1. Reset removes CUPS and the PDF printer
again.

## Tasks

1. Install `cups` and a PDF printer, and find it with `lpstat -p`. On
   Debian and Ubuntu, install `printer-driver-cups-pdf` and `cups-bsd`; the
   first adds a printer named `PDF` by itself. On the RHEL family,
   `cups-pdf` comes from EPEL (`dnf install epel-release` first) and adds
   no printer, so add one:
   `lpadmin -p PDF -E -v cups-pdf:/ -m CUPS-PDF_opt.ppd`. As `alice`, print
   a text file to it (a job printed by root makes no PDF on the RHEL
   family); find the PDF it makes, and write the PDF's full path to
   `/root/lab-answers/1`.
2. Disable the printer with a reason, print two files, list them with `lpq`
   and `lpstat -o`, remove one with `lprm` and the other with `cancel`, then
   enable it again. Also reject jobs on the printer and try to print; read
   the message, then accept jobs again.
3. Turn on CUPS's debug logging, print a file, and read what `error_log`
   (or `journalctl -u cups`) shows. Leave debug logging on.

## Hints

- `lpstat -p -v`; `lp -d PRINTER file`. The PDF lands in `~/PDF` on Debian
  and Ubuntu; on the RHEL family it goes to `~/Desktop`, or the home
  directory when there's no Desktop. `lpinfo -m | grep -i pdf` lists the
  PDF printer's driver.
- `cupsdisable -r "reason"`, `cupsenable`, `cupsreject -r`, `cupsaccept`;
  `lpstat -p -l`. On Debian and Ubuntu, `lpq` and `lprm` are in the
  `cups-bsd` package.
- `cupsctl --debug-logging`, `cupsctl`; `/var/log/cups/error_log`.
