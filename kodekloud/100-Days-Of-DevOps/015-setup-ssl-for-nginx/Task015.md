# Task 015 - Setup SSL for Nginx

The system admins team of xFusionCorp Industries needs to deploy a new application on App Server 2 in Stratos Datacenter. They have some pre-requites to get ready that server for application deployment. Prepare the server as per requirements shared below:

1. Install and configure `nginx` on App Server 2.

2. On App Server 2 there is a self signed SSL certificate and key present at location `/tmp/nautilus.crt` and `/tmp/nautilus.key`. Move them to some appropriate location and deploy the same in Nginx.

3. Create an index.html file with content Welcome! under Nginx document root.

4. For final testing try to access the App Server 2 link (either hostname or IP) from jump host using curl command. For example curl -Ik https://<app-server-ip>/.

## App Server 2 Details

- **Server Name**: `stapp02`
- **IP**: `172.16.238.11`
- **Host Name**: `stapp02.stratos.xfusioncorp.com`
- **User**: `steve`

## NGINX Guide

### 1) Install + enable NGINX (on `stapp02`)

```bash
sudo dnf -y install nginx
sudo systemctl enable --now nginx
sudo systemctl status nginx --no-pager
```

### 2) Move the self-signed cert/key to standard locations

```bash
sudo mkdir -p /etc/pki/tls/certs /etc/pki/tls/private

sudo mv /tmp/nautilus.crt /etc/pki/tls/certs/nautilus.crt
sudo mv /tmp/nautilus.key /etc/pki/tls/private/nautilus.key

sudo chown root:root /etc/pki/tls/certs/nautilus.crt /etc/pki/tls/private/nautilus.key
sudo chmod 644 /etc/pki/tls/certs/nautilus.crt
sudo chmod 600 /etc/pki/tls/private/nautilus.key
```

### 3) Create the required home page under NGINX docroot

Default docroot on this distro: `/usr/share/nginx/html`

```bash
echo 'Welcome!' | sudo tee /usr/share/nginx/html/index.html >/dev/null
```

### 4) Configure HTTPS in `/etc/nginx/conf.d/ssl.conf`

Create/update this file (preferred over editing `nginx.conf` directly):

```nginx
server {
    listen 443 ssl;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    ssl_certificate     /etc/pki/tls/certs/nautilus.crt;
    ssl_certificate_key /etc/pki/tls/private/nautilus.key;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Validate + reload:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

### 5) Test from jumphost (self-signed cert => use `-k/--insecure`)

Plain `curl https://...` fails with `SSL certificate problem: self-signed certificate`.
Use:

```bash
curl -Ik https://172.16.238.11/
# or
curl --insecure -I https://172.16.238.11/
```

Expected: `HTTP/1.1 200 OK`

```bash
thor@jumphost ~$ curl -Ik https://172.16.238.11
HTTP/1.1 200 OK
Server: nginx/1.20.1
Date: Thu, 25 Dec 2025 13:44:11 GMT
Content-Type: text/html
Content-Length: 9
Last-Modified: Thu, 25 Dec 2025 13:23:20 GMT
Connection: keep-alive
ETag: "694d3ac8-9"
Accept-Ranges: bytes

thor@jumphost ~$ curl -k https://172.16.238.11/
Welcome!
```
