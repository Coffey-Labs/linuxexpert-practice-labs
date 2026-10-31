# LFCA 3.2: Performance and availability

The downtime each number of nines allows, and nginx as a load balancer in
front of two web servers.

## Before you start

Work as root (`sudo -i`). Answers go in `/root/lab-answers/<task>`.

The peer, at `10.99.0.2` (name `peer`), stands in for the two web server
VMs: it runs one web server on port 8081 and another on port 8082, each
with its own home page (`le-lab-backend1.service` and
`le-lab-backend2.service` on this VM). This VM is the load balancer. The
lab notes whether nginx is installed, and reset puts that back. The VM
needs internet access to install nginx.

## Tasks

1. Work out the yearly downtime allowed by 99.9%, 99.95% and 99.99%, in
   minutes, and check them against the chapter's table. Write them to
   `/root/lab-answers/1`, one per line, in that order.
2. Install nginx on this VM and make it a load balancer on port 80: an
   `upstream` block with `zone backend 64k;` and the two servers
   (`10.99.0.2:8081` and `10.99.0.2:8082`), and `proxy_pass`. Run
   `for i in 1 2 3 4 5 6; do curl -s http://localhost/; done` and watch
   the answers alternate. Leave nginx running and starting at boot.
3. Stop one web server (`systemctl stop le-lab-backend2`) and watch the
   traffic move to the other. Start it again afterwards. Not graded.

## Hints

- A year has 365 × 24 × 60 = 525,600 minutes; 99.9% allows 0.1% of that.
- A file in `/etc/nginx/conf.d/` with `upstream backend { ... }` and a
  `server { listen 80; location / { proxy_pass http://backend; } }`.
  `nginx -t`, `systemctl enable --now nginx`, `systemctl reload nginx`.
- Only one server block can answer for port 80 by default. On Ubuntu,
  remove the `default` link in `/etc/nginx/sites-enabled/`.
- A 502 Bad Gateway on the RHEL family with SELinux enforcing: nginx may
  not connect out until you allow it with
  `setsebool -P httpd_can_network_connect on`.
