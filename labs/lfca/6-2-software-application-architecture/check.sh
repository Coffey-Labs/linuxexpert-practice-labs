# A table in ~/shop.db with at least three rows, read without the sqlite3 tool.
three_rows() {
	python3 -I - <<'X'
import sqlite3, sys
db = sqlite3.connect("file:/root/shop.db?mode=ro", uri=True)
tables = [r[0] for r in db.execute("select name from sqlite_master where type = 'table'")]
sys.exit(0 if any(db.execute('select count(*) from "%s"' % t.replace('"', '""')).fetchone()[0] >= 3 for t in tables) else 1)
X
}

task 1 "The git/git repository's description in /root/lab-answers/1"
need "jq is installed" 'command -v jq'
need "the answer is the description from the API" 'grep -qi "git source code mirror" /root/lab-answers/1'

task 2 "The status code for a missing repository in /root/lab-answers/2"
need "the answer is the HTTP status code" '[ "$(answer 2)" = 404 ]'

task 3 "SQLite: ~/shop.db with a table of three rows"
need "sqlite3 is installed" 'command -v sqlite3'
need "/root/shop.db is an SQLite database" '[ -f /root/shop.db ] && head -c 15 /root/shop.db | grep -q "SQLite format"'
need "it has a table with at least three rows" three_rows
