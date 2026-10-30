# RHCSA 8.4: Restricting network access with firewalld

Allowing services permanently, the difference between runtime and
permanent rules, and saving the runtime configuration.

## Before you start

The lab installs and starts firewalld if it isn't running, and notes its
configuration so reset can put it back. Work in the zone of the main
interface (the default zone, `public`, on a fresh system), and keep a
console open: a firewall mistake can cut off SSH.

Tasks 2 and 3 end where they started, so the lab runs a small service,
`le-lab-watch`, that notes the zone's services and ports every couple of
seconds for the check. Wait a few seconds between steps.

## Tasks

1. Allow HTTP and HTTPS through the firewall permanently, and nothing else
   new. After a reboot, `firewall-cmd --list-services` shows `http` and
   `https` added to the services that were there before, and
   `firewall-cmd --list-ports` is empty.
2. Allow TCP port 8080 at runtime only, see it in `firewall-cmd
   --list-ports`, then reload and see it gone.
3. Allow the `ftp` service at runtime, then save the runtime configuration
   as permanent, then remove `ftp` permanently again and reload.

## Hints

- `firewall-cmd --permanent --add-service=`, `--reload`,
  `--list-services`, `--list-ports`, `--list-all`.
- `firewall-cmd --add-port=8080/tcp` (no `--permanent`), `--reload`.
- `firewall-cmd --runtime-to-permanent`; `--permanent --list-services`;
  `--permanent --remove-service=ftp`.
