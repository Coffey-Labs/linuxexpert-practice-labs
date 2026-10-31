# Ubuntu Server 1.4: A web application with a database

Apache, PHP and MySQL: a database with a read-only user, a PHP page in a
virtual host of its own, and finding a broken database login in the logs.

## Before you start

The lab doesn't install anything: installing Apache, PHP and MySQL is part
of task 1. It checks that nothing listens on port 80 yet. Reset removes
the packages installed during the lab again, with MySQL's databases.

## Tasks

1. Install Apache, PHP and MySQL. Create a database `shop` with a table
   `item` holding two rows, and a user `shopapp` (at `localhost`) who can
   only read it. `mysql -u shopapp -p shop -e 'SELECT * FROM item;'` shows
   the two rows, and `mysql -u shopapp -p shop -e 'DELETE FROM item;'`
   fails with "DELETE command denied".
2. Serve a PHP page that lists the items, as a virtual host named
   `shop.example.test` with its own error log. `curl -H 'Host:
   shop.example.test' http://localhost/` prints the two items; `apache2ctl
   -S` lists `shop.example.test`; `curl http://localhost/` still shows
   Ubuntu's default page.
3. Break the page by changing the database password in it, so that `curl -s
   -o /dev/null -w '%{http_code}' -H 'Host: shop.example.test'
   http://localhost/` prints `500`, and find the cause from the logs alone:
   the site's error log shows "Access denied for user
   'shopapp'@'localhost'". Then put it back.

## Hints

- `apt install apache2 mysql-server php libapache2-mod-php php-mysql`;
  `sudo mysql`, `CREATE DATABASE`, `CREATE TABLE`, `INSERT`, `CREATE USER
  ... IDENTIFIED BY`, `GRANT SELECT ON shop.* TO`.
- A file in `/etc/apache2/sites-available/` with `<VirtualHost *:80>`,
  `ServerName`, `DocumentRoot`, `DirectoryIndex index.php`, `ErrorLog
  ${APACHE_LOG_DIR}/...`; `a2ensite`, `apache2ctl configtest`, `systemctl
  reload apache2`. In PHP, `new mysqli(...)`, `query()`, `fetch_assoc()`.
- `tail` the site's error log in `/var/log/apache2/`.
