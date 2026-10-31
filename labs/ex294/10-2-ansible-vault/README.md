# EX294 10.2: Ansible Vault

Keep a user's password in an encrypted variables file, use it to create
the user, change the vault password, and run the playbook with
ansible-navigator, with a password file and at the prompt.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) with an SSH key, and installs `ansible-core` and
`ansible-navigator`. Work as greg, in `/home/greg/ansible`: its
`ansible.cfg` reads the inventory `inventory`, logs in as `devops` and
becomes root. Its `ansible-navigator.yml` turns execution environments
off, so ansible-navigator runs this VM's own `ansible-playbook` and pulls
no container image.

The managed node `node1` (10.99.1.11) is an AlmaLinux 10 container
reached over SSH by name, where `devops` has greg's key and passwordless
sudo. For a root shell on it, `sudo podman exec -it node1 bash`.

## Tasks

1. In `/home/greg/ansible`, store the vault password `RedhatVault` in
   `vault-pass.txt` (mode 600), and create the encrypted variables file
   `secret.yml` with `user_password` set to a password of your choosing.
   Write `vault.yml`, which uses `secret.yml` to create the user
   `vaultuser` on node1 with that password, and run it.
2. Change the vault password of `secret.yml`, and put the new one in
   `vault-pass.txt`. Then `ansible-vault view` works with the new
   password and fails with `RedhatVault`.
3. Run `vault.yml` with ansible-navigator, first with
   `--vault-password-file vault-pass.txt`, then with `--ask-vault-pass`.
   Set `ansible-navigator.yml` up so the prompt works: stdout mode, and
   playbook artifacts off.

## Hints

- `ansible-vault create`, `encrypt`, `view`, `rekey`
  (`--new-vault-password-file`).
- `vars_files: [secret.yml]`, and
  `password: "{{ user_password | password_hash('sha512', 'vaultsalt') }}"`
  with `update_password: on_create`.
- In `ansible-navigator.yml`: `mode: stdout` and `playbook-artifact:` with
  `enable: false`, beside the `execution-environment` setting. With
  artifacts on, `--ask-vault-pass` shows no prompt and waits.
