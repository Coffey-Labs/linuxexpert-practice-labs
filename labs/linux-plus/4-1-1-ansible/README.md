# Linux+ 4.1.1: Ansible

An inventory, ad hoc commands, and a playbook that installs a package,
manages a file and starts a service, run until it changes nothing.

## Before you start

The VM needs internet access. This one VM is both the control node and the
managed host: Ansible reaches it over SSH at `127.0.0.1`. The lab creates
user `alice` (password `Lab-Pass-1`), who may use sudo with her password,
installs `at` and stops and disables `atd`. Work as alice for the
Ansible tasks (`sudo -iu alice` is fine). `le-lab reset` puts `/etc/motd`
back.

## Tasks

1. Install Ansible. As alice, set up key-based SSH from alice to
   `alice@127.0.0.1`, and write `~/ans/inventory.ini` with a group `lab`
   that holds `127.0.0.1` with `ansible_user=alice`. Run the `ping` and
   `setup` modules against `lab`.
2. Write `~/ans/site.yml`, a play for `lab` that becomes root and installs
   `tree`, writes `/etc/motd` with the content `Managed by Ansible on
   <distribution>` (from the facts), and makes `atd` run and start at boot.
   Run it with `--check --diff` first, then for real, then again to see
   everything `ok`. Finally change `/etc/motd` by hand, run the playbook
   once more, and watch it put the content back.

## Hints

- `ansible-core` on RHEL relatives, `ansible` on Ubuntu.
- `ssh-keygen`; on one machine you can append your public key to
  `~/.ssh/authorized_keys` yourself; `ssh 127.0.0.1 true` once to accept the
  host key.
- `ansible lab -i inventory.ini -m ping`, `-m setup -a
  'filter=ansible_distribution*'`.
- `ansible.builtin.package`, `ansible.builtin.copy` with `content:`,
  `ansible.builtin.service`; `become: true` and `-K` for alice's sudo
  password; `ansible-playbook --check --diff`.
