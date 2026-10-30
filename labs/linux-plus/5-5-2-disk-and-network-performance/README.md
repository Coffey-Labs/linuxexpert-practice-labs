# Linux+ 5.5.2: Disk and network performance

A process that keeps the disk busy, latency on a link, and throughput
measured with iperf3.

## Before you start

The lab installs sysstat and starts a service that writes to disk all the
time. The peer, at `10.99.0.2` (name `peer`), is another machine on this
VM's second network, `10.99.0.0/24`; this VM is `10.99.0.1` there, on
interface `le-host`. Get a shell there with `sudo ip netns exec lepeer
bash`; it shares this VM's programs. The lab has slowed that network down
on purpose. None of the slowdowns lasts past a reboot: do the tasks and
check without rebooting. Write answers to the files in
`/root/lab-answers/`.

## Tasks

1. Watch disk latency and utilization with `iostat -xz 1`. Find the
   process that keeps writing, write the name of its service to
   `/root/lab-answers/1`, and stop it for good.
2. Measure latency and jitter from this VM to the peer with `ping -c 20
   -i 0.2 10.99.0.2`. Write the average round-trip time, in milliseconds,
   to `/root/lab-answers/2`. Then find what delays the packets on this
   VM's side of the link, and remove it.
3. Install `iperf3`, run a server on this VM (`iperf3 -s`), opening port
   5201/tcp in the firewall if one is running, and measure the throughput
   from the peer with `iperf3 -c 10.99.0.1 -t 5`. Write the result, in
   Mbit/s, to `/root/lab-answers/3`. Then find what limits it on the
   peer's side of the link, remove it, and measure again.

## Hints

- `iostat -xz 1` (`%util`, `w_await`), `pidstat -d 1`, `ps -o unit= -p
  PID`, `systemctl disable --now`.
- `tc qdisc show dev le-host`, `tc qdisc del dev DEV root`; on the peer,
  `tc qdisc show dev le-peer`.
- `firewall-cmd --add-port=5201/tcp` (and `--permanent`), `ufw allow`;
  `iperf3 -c ADDRESS -t 5`, `-R` for the other direction.
