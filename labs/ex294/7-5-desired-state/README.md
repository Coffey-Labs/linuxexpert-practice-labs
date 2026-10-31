# EX294 7.5: Desired state

Change a configuration file and restart the service only when the file
changed, with handlers: by name, by a `listen` topic, and after a failure.

## Before you start

This VM is the control node. The lab creates the user `greg` (password
`Lab-Pass-1`) and installs `ansible-core`. Work as greg, in
`/home/greg/ansible`: its `ansible.cfg` reads the inventory `inventory`,
logs in to the nodes as `devops` with greg's SSH key, and becomes root.

The managed nodes `node1` (10.99.1.11) and `node2` (10.99.1.12) are
AlmaLinux 10 containers in the group `webservers`, each with httpd
installed and running with its stock `/etc/httpd/conf/httpd.conf`. For a
root shell on a node, `sudo podman exec -it node1 bash`.

## Tasks

1. Write `/home/greg/ansible/web.yml`, which sets `ServerTokens Prod` in
   `/etc/httpd/conf/httpd.conf` on the web servers and restarts httpd only
   when the file changed. The first run shows `RUNNING HANDLER`, the
   second doesn't and reports `changed=0`. Afterwards
   `curl -sI http://node1/` shows `Server: Apache` without a version.
2. Write `/home/greg/ansible/listen.yml`, which sets `KeepAlive On` in the
   same file and notifies one `listen` topic that two handlers listen to.
   Both run, in the order they're defined.
3. Write `/home/greg/ansible/force.yml`, which sets `Timeout 120` in the
   same file, notifies a handler that restarts httpd, and then runs a task
   that fails. Get the handler to run anyway. Without `force_handlers` the
   handler doesn't run; with it, it does.

## Hints

- `lineinfile` with `regexp` and `line`, and `notify:` with the handler's
  exact name.
- Handlers take `listen: TOPIC`; the task notifies the topic.
- `force_handlers: true` on the play, or `--force-handlers`.
- To see a handler run again, take the line out first:
  `ansible webservers -m lineinfile -a "path=... regexp=^Timeout state=absent"`.
