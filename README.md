# LINUXexpert practice labs

Hands-on labs to work through alongside the
[LINUXexpert study guides](https://linuxexpert.net/guides/). Each lab sets
up a scenario on your own virtual machine, gives you the tasks from a guide
chapter's "Try it" section, and grades your work.

Grading is rough on purpose. It checks the result (is the user there, does
the service answer, does the mount survive a reboot), not the commands you
typed, so any correct approach passes. These labs are for practice. They
aren't the exams, and they don't contain exam questions.

## What you need

- A **throwaway virtual machine**. Labs add users, disks, services and
  firewall rules, and some tasks break the boot on purpose. `le-lab` refuses
  to run outside a VM.
- One of the systems the labs are tested on: **AlmaLinux 10** (or another
  RHEL 10 relative) or **Ubuntu 24.04 LTS**. Each lab says which it supports.
- Internet access from the VM, for installing packages.
- About 2 GB of memory and 20 GB of disk. You don't need extra disks or
  network cards: labs that need them make loop devices and network
  namespaces.

Take a snapshot of the VM before you start a lab, so you can always go back.

## Getting started

```sh
git clone https://git.coffeylabs.org/coffey-labs/linuxexpert-practice-labs.git
cd linuxexpert-practice-labs
./le-lab list lfcs
sudo ./le-lab start lfcs/5-1-user-group-accounts
```

Studying for one exam? Each guide chapter with a lab also offers that
guide's labs as one download, such as `lfcs.tar.gz`. Unpack it and run
`le-lab` the same way from its `linuxexpert-labs-lfcs` folder. Cloning gets
every guide's labs and lets you update them with `git pull`.

`start` sets the lab up and prints the tasks. Work on them in any order,
then:

```sh
sudo ./le-lab check     # grade your work; run it as often as you like
sudo ./le-lab tasks     # show the tasks again
sudo ./le-lab reset     # undo the lab when you're done
```

A check prints one line per task:

```
  [PASS] 1   carol: UID 2001, /bin/sh, home, group developers, change at first login
  [FAIL] 2   carol's passwords expire after 60 days, warning 10 days before
         not yet: maximum password age is 60
  [SKIP] 4   ... (RHEL family only)
  [SELF] 5   ... (not graded: check it yourself)

Score: 3 of 4 tasks (75%)
```

Some tasks ask you to write what you found to a file under
`/root/lab-answers/`. Tasks that say "after a reboot" are only really done
when the check passes after you reboot.

`reset` removes what the lab set up and undoes the tasks' usual changes, but
it can't know everything you tried. For a clean VM, go back to your
snapshot.

## Labs

| Guide | Labs |
| --- | --- |
| [LFCS](https://linuxexpert.net/lfcs/) | `labs/lfcs/`, one per chapter |

Each lab's `README.md` lists its tasks and links its study guide chapter.

## Problems

If a lab grades something wrong, or won't set up on a supported system,
please open an issue with the lab's name, your system (`cat
/etc/os-release`) and the output of `sudo ./le-lab check`.

## License

MIT, see [LICENSE](LICENSE). Copyright (C) 2026 Coffey Labs LLC.
