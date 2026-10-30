pkg_install nginx
# Reset puts nginx's configuration back as it was.
rm -rf "$LAB_STATE/nginx.orig"
cp -a /etc/nginx "$LAB_STATE/nginx.orig"
systemctl enable --quiet --now nginx
hosts_add "127.0.0.1 web1.example.org www.example.org"
rm -rf /root/tls
mkdir -m 700 /root/tls
