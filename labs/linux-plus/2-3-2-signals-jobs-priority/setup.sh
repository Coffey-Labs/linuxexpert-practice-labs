for c in 'sleep 1000' 'sleep 1001'; do
	! pgrep -fx "$c" >/dev/null || refuse "a process '$c' is already running; stop it first"
done
user_add alice
# As if alice had typed them: argv[0] is the bare name, as in a shell.
for n in 1000 1001; do
	systemd-run --quiet --uid=alice --unit=le-lab-sleep$n /bin/bash -c "exec -a sleep /usr/bin/sleep $n"
done
systemd-run --quiet --uid=alice --unit=le-lab-yes -p Nice=15 -p StandardOutput=null /bin/bash -c 'exec -a yes /usr/bin/yes'
