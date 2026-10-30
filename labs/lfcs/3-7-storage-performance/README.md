# LFCS 3.7: Storage performance

Finding a busy disk and the process behind it, measuring a disk with fio,
I/O schedulers, and keeping disk history with sysstat.

## Before you start

The lab adds three spare disks, which come back at every boot:

- `/dev/loop40` (1 GiB), with an ext4 filesystem mounted at `/data`, for
  your test files;
- `/dev/loop41` (256 MiB), empty, for the scheduler tasks;
- `/dev/loop42` (256 MiB), which a process the lab started keeps busy.

If sysstat collection was on, the lab turns it off.

## Tasks

1. One disk is busy. Find the busiest device and the process responsible.
   Write the device name (such as `vdb`) on the first line of
   `/root/lab-answers/1`, and the process's command name (as `ps` or
   `iotop` shows it) on the second line.
2. Measure `/data`'s disk with fio, using a test file in `/data`: first
   sequential write throughput, then random 4 KiB read IOPS. Write the
   first test's `BW=` figure (such as `188MiB/s`) on the first line of
   `/root/lab-answers/2` and the second test's `IOPS=` figure (such as
   `48.2k`) on the second line. Remove the test file afterwards.
3. Find the I/O scheduler of `/dev/loop41` and write its name to
   `/root/lab-answers/3`. Then change it to `mq-deadline` until the next
   reboot.
4. Make that scheduler choice for `/dev/loop41` survive a reboot.
5. Turn on sysstat collection and, once it has collected some data, show
   today's disk activity.

## Hints

- `iostat -xz 2` (ignore the first report), `sudo iotop -o`, `pidstat -d 2`
  (packages `sysstat` and `iotop`).
- `fio --name=... --filename=/data/fio.test --rw=write --bs=1M --size=...
  --direct=1`, then `--rw=randread --bs=4k`.
- `cat /sys/block/loop41/queue/scheduler`; `echo ... | sudo tee` it.
- A rule in `/etc/udev/rules.d/` (`KERNEL==`, `ATTR{queue/scheduler}=`),
  `udevadm control --reload`, `udevadm trigger`.
- `systemctl enable --now sysstat`; data comes every 10 minutes (the `sa1`
  in `/usr/lib64/sa/` or `/usr/lib/sysstat/` collects a sample by hand:
  `sa1 1 2`); `sar -d -p`.
