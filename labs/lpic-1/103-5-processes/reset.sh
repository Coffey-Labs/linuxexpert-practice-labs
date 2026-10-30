# tmux servers running a top: end them.
for p in $(pgrep -x top); do
	q=$p
	while [ -n "$q" ] && [ "$q" -gt 1 ]; do
		case $(ps -o comm= -p "$q") in tmux*) kill "$q" 2>/dev/null; break ;; esac
		q=$(ps -o ppid= -p "$q" | tr -d ' ')
	done
done
true
