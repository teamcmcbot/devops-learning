# Task 016 - Install and Configure Nginx as Load Balancer

Day by day traffic is increasing on one of the websites managed by the Nautilus production support team. Therefore, the team has observed a degradation in website performance. Following discussions about this issue, the team has decided to deploy this application on a high availability stack i.e on Nautilus infra in Stratos DC. They started the migration last month and it is almost done, as only the LBR server configuration is pending. Configure LBR server as per the information given below:

a. Install `nginx` on `LBR` (load balancer) server.

b. Configure load-balancing with the an `http` context making use of all `App Servers`. Ensure that you update only the main Nginx configuration file located at `/etc/nginx/nginx.conf`.

c. Make sure you do not update the apache port that is already defined in the apache configuration on all app servers, also make sure apache service is up and running on all app servers.

d. Once done, you can access the website using StaticApp button on the top bar.

## Solution Steps

1. **Access the Load Balancer Server**:
   - Log in to the `LBR` server using SSH.
2. **Install Nginx using dnf**:
   - Run the following command to install Nginx:
     ```bash
     sudo dnf install nginx -y
     ```
3. **Start and Enable Nginx Service**:
   - Start the Nginx service and enable it to start on boot:
     ```bash
     sudo systemctl start nginx
     sudo systemctl enable nginx
     ```
4. **Configure Nginx as a Load Balancer**:

**Current nginx.conf file**:

```nginx
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        error_page 404 /404.html;
#            location = /40x.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#            location = /50x.html {
#        }
#    }

}
```

### Check which port Apache is running on app servers

```bash
[steve@stapp02 ~]$ sudo ss -tulpn
Netid       State         Recv-Q        Send-Q               Local Address:Port                Peer Address:Port       Process
udp         UNCONN        0             0                       127.0.0.11:45236                    0.0.0.0:*
tcp         LISTEN        0             511                        0.0.0.0:8088                     0.0.0.0:*           users:(("httpd",pid=1665,fd=3),("httpd",pid=1664,fd=3),("httpd",pid=1663,fd=3),("httpd",pid=1655,fd=3))
tcp         LISTEN        0             128                        0.0.0.0:22                       0.0.0.0:*           users:(("sshd",pid=1341,fd=3))
tcp         LISTEN        0             4096                    127.0.0.11:45785                    0.0.0.0:*
tcp         LISTEN        0             128                           [::]:22                          [::]:*           users:(("sshd",pid=1341,fd=4))

[steve@stapp02 ~]$ sudo ss -tulpn
Netid       State         Recv-Q        Send-Q               Local Address:Port                Peer Address:Port       Process
udp         UNCONN        0             0                       127.0.0.11:45236                    0.0.0.0:*
tcp         LISTEN        0             511                        0.0.0.0:8088                     0.0.0.0:*           users:(("httpd",pid=1665,fd=3),("httpd",pid=1664,fd=3),("httpd",pid=1663,fd=3),("httpd",pid=1655,fd=3))
tcp         LISTEN        0             128                        0.0.0.0:22                       0.0.0.0:*           users:(("sshd",pid=1341,fd=3))
tcp         LISTEN        0             4096                    127.0.0.11:45785                    0.0.0.0:*
tcp         LISTEN        0             128                           [::]:22                          [::]:*           users:(("sshd",pid=1341,fd=4))

[banner@stapp03 ~]$ sudo ss -tulpn
Netid       State         Recv-Q        Send-Q               Local Address:Port                Peer Address:Port       Process
udp         UNCONN        0             0                       127.0.0.11:52238                    0.0.0.0:*
tcp         LISTEN        0             4096                    127.0.0.11:37395                    0.0.0.0:*
tcp         LISTEN        0             511                        0.0.0.0:8088                     0.0.0.0:*           users:(("httpd",pid=1670,fd=3),("httpd",pid=1669,fd=3),("httpd",pid=1668,fd=3),("httpd",pid=1660,fd=3))
tcp         LISTEN        0             128                        0.0.0.0:22                       0.0.0.0:*           users:(("sshd",pid=1227,fd=3))
tcp         LISTEN        0             128                           [::]:22                          [::]:*           users:(("sshd",pid=1227,fd=4))

```

**NOTE:** Apache is running on port `8088` on app servers.

### Add the following to nginx.conf file:

```nginx
http {
    # ...existing code...

    upstream backend {
        server stapp01:8088;
        server stapp02:8088;
        server stapp03:8088;
    }

    # ...existing code...

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;

        location / {
            proxy_pass http://backend;
        }

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

    # ...existing code...
}

```

Changes Made

- Removed: root /usr/share/nginx/html;
- Removed: include /etc/nginx/default.d/\*.conf;
- Added: location / { proxy_pass http://backend; }

5. **Test and restart nginx**:

   - Test the Nginx configuration for syntax errors:
     ```bash
     sudo nginx -t
     ```
   - If the test is successful, restart Nginx to apply the changes:
     ```bash
     sudo systemctl restart nginx
     ```

6. Verify the Static App button is displaying the web page correctly.

https://80-port-2cva7cbknxopnpzf.labs.kodekloud.com/

```text
Welcome to xFusionCorp Industries!
```
