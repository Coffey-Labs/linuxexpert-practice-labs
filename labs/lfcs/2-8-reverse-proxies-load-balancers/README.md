# LFCS 2.8: Reverse proxies and load balancers

nginx as a reverse proxy and load balancer, sticky balancing, HAProxy with
health checks, and passing on the client's address.

## Before you start

The lab runs three back ends on this VM, on `127.0.0.1:8081`, `8082` and
`8083` (units `le-backend@8081` and so on). Each answers with a page that
names it, such as `Back end 8081`, and logs the `X-Forwarded-For` header it
receives (`journalctl -u le-backend@8081`). nginx and HAProxy aren't
installed.

The peer, at `10.99.0.2`, is the other VM: test from there with
`sudo ip netns exec lepeer curl http://10.99.0.1/`. Open the ports you use
in the firewall if one runs.

## Tasks

1. Put nginx on port 80 in front of the back end on 8081 (on the RHEL
   family with SELinux enforcing), so `curl http://10.99.0.1/` from the
   peer returns the back end's page.
2. Balance the requests to port 80 across the back ends with nginx: 8081
   and 8082 in turn, with 8083 as a backup.
3. On port 81, balance across the same back ends with nginx, sticky by
   client address (without `backup`), so repeated requests from one host
   always reach the same back end.
4. Ubuntu: do the balancing of task 2 with HAProxy on port 8080, with
   health checks, so a stopped back end leaves the rotation within a few
   seconds.
5. Make the back ends behind port 80 receive the real client's address in
   an `X-Forwarded-For` header.

## Hints

- `upstream`, `proxy_pass`, `server ... backup`, `ip_hash`; `nginx -t`,
  then reload. On Ubuntu, the `default` site in `sites-enabled` is the
  default server for port 80.
- RHEL: a 502 with SELinux enforcing means `ausearch -m avc` and
  `setsebool -P httpd_can_network_connect`.
- `frontend`, `backend`, `balance roundrobin`, `server ... check`,
  `option httpchk GET /`; `haproxy -c -f /etc/haproxy/haproxy.cfg`.
- `proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for`.
- `systemctl stop le-backend@8081` to test failover.
