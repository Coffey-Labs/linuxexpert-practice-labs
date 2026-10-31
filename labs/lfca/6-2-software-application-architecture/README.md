# LFCA 6.2: Software application architecture

Calling a REST API and reading its JSON, HTTP status codes, and a first
SQL database.

## Before you start

Work as root (`sudo -i`), so `~` is `/root`. Answers go in
`/root/lab-answers/<task>`. The VM needs internet access. The lab notes
whether `jq` and SQLite are installed, and reset removes the ones it
didn't find.

## Tasks

1. Call a public REST API with curl and read the JSON:
   `curl -s https://api.github.com/repos/git/git`. Install `jq` if it's
   missing, pick out the repository's description with `jq .description`,
   and write it to `/root/lab-answers/1`.
2. Request a repository that doesn't exist with `curl -i` (for example
   `https://api.github.com/repos/git/no-such-repo`), find the HTTP status
   code, and write it to `/root/lab-answers/2`.
3. Install SQLite (`sqlite3` on Ubuntu, `sqlite` on the RHEL family). In
   a database `~/shop.db`, create a table, insert three rows and query
   them with SQL.

## Hints

- `curl -s URL | jq .`, `jq -r .description`.
- The status code is on the first line of `curl -i`'s output; `curl -s -o
  /dev/null -w '%{http_code}\n' URL` prints only the code.
- `sqlite3 ~/shop.db`, then `CREATE TABLE products (id INTEGER PRIMARY KEY,
  name TEXT, price REAL);`, `INSERT INTO products (name, price) VALUES
  ('mug', 9.5);`, `SELECT * FROM products;`, `.tables`, `.quit`.
