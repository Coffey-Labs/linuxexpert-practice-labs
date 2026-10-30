# A top process whose ancestors include a tmux server.
top_in_tmux() {
	local p q
	for p in $(pgrep -x top); do
		q=$p
		while [ -n "$q" ] && [ "$q" -gt 1 ]; do
			case $(ps -o comm= -p "$q") in tmux*) return 0 ;; esac
			q=$(ps -o ppid= -p "$q" | tr -d ' ')
		done
	done
	return 1
}
# The biggest memory user in the answer is one of the biggest three now.
mem_ok() {
	local first top3
	[ "$(grep -c '[0-9]' /root/lab-answers/4 2>/dev/null)" -ge 5 ] || return 1
	first=$(grep -m1 -oE '[0-9]+' /root/lab-answers/4)
	top3=$(ps -eo pid=,comm= --sort=-rss | head -n 3)
	printf '%s\n' "$top3" | awk -v p="$first" '$1 == p {ok = 1} END {exit !ok}'
}

task 1 "A job stopped, resumed and ended" self

task 2 "top runs in a detached tmux session"
need "a tmux session is running" 'pgrep -f "^tmux" >/dev/null'
need "top runs inside it" top_in_tmux

task 3 "Three sleeps ended with one pkill" self

task 4 "The five biggest memory users"
need "/root/lab-answers/4 lists five processes, the first one among the three biggest now" mem_ok

task 5 "A CPU loop watched and killed" self
