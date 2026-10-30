# Linux+ 4.1.2: Puppet and OpenTofu

A Puppet manifest applied without a server, and an OpenTofu configuration
planned, applied and destroyed with a provider that needs no cloud
account.

## Before you start

Work as root, so `~` is `/root`. The VM needs internet access to add the
OpenVox and OpenTofu package repositories. The lab only checks that
`~/lab.pp`, `~/tofu` and `/tmp/puppet-lab.txt` don't exist yet.
`le-lab reset` removes those files but leaves the packages installed.

## Tasks

1. Add the OpenVox 8 repository for your system (see voxpupuli.org) and
   install `openvox-agent`. Write `~/lab.pp`, a manifest that manages
   `/tmp/puppet-lab.txt` with mode 0644 and the content `Managed by Puppet
   on <OS name>` (from the `os.name` fact). Apply it with `--noop` first,
   then for real, and ask facter for `os.family`.
2. Install OpenTofu from opentofu.org's packages. In `~/tofu`, write a
   `main.tf` with a `terraform_data` resource named `hello` whose input is
   `hello from OpenTofu`, and an output `msg` with its output. Run `tofu
   init`, `plan` and `apply`, look at the state, and then destroy it.

## Hints

- The release package `openvox8-release-el-10.noarch.rpm` (or
  `openvox8-release-ubuntu24.04.deb`), then `openvox-agent`;
  `/opt/puppetlabs/bin/puppet apply --noop`, `/opt/puppetlabs/bin/facter`.
- A `file { '/tmp/puppet-lab.txt': ... }` resource with `ensure`,
  `content` and `mode`; `${facts['os']['name']}` in a double-quoted string.
- The installer script `install-opentofu.sh` with `--install-method rpm`
  or `deb`; `tofu init`, `tofu plan`, `tofu apply -auto-approve`,
  `tofu state list`, `tofu destroy -auto-approve`.
