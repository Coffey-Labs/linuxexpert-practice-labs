if [ -f "$LAB_STATE/index.db" ] && [ ! -f /var/cache/man/index.db ]; then
	mv "$LAB_STATE/index.db" /var/cache/man/index.db
	restorecon /var/cache/man/index.db 2>/dev/null
fi
true
