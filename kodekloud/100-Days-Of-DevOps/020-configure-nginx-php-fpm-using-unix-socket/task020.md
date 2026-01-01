# Task 020: Configure Nginx & PHP-FPM using Unix Socket

The Nautilus application development team is planning to launch a new PHP-based application, which they want to deploy on Nautilus infra in Stratos DC. The development team had a meeting with the production support team and they have shared some requirements regarding the infrastructure. Below are the requirements they shared:

a. Install `nginx` on `app server 2` , configure it to use port `8098` and its document root should be /var/www/html.

b. Install `php-fpm` version `8.1` on `app server 2`, it must use the unix socket /var/run/php-fpm/default.sock (create the parent directories if don't exist).

c. Configure php-fpm and nginx to work together.

d. Once configured correctly, you can test the website using `curl http://stapp02:8098/index.php` command from jump host.

NOTE: We have copied two files, `index.php` and `info.php`, under `/var/www/html` as part of the PHP-based application setup. Please do not modify these files.

## Solution Steps

1. **Access the Application Server:**

   ```bash
   ssh steve@stapp02
   ```

2. **Install Nginx:**

   ```bash
   sudo dnf install nginx -y
   ```

3. **Configure /etc/nginx/nginx.conf**

- listen on port 8098
- set root to /var/www/html
- configure php-fpm to use unix socket /var/run/php-fpm/default.sock\*\*

  Edit the Nginx configuration file:

  ```bash
  sudo vi /etc/nginx/nginx.conf
  ```

  Update the server block as follows:

```nginx
server {
        listen       8098;
        listen       [::]:8098;
        server_name  _;
        root         /var/www/html;
        index index.php index.html index.htm;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
           try_files $uri $uri/ =404;
        }

        # Pass PHP requests to PHP-FPM via Unix socket
        location ~ \.php$ {
           fastcgi_pass unix:/var/run/php-fpm/default.sock;
           fastcgi_index index.php;
           fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
           include fastcgi_params;
        }

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

3. **Install PHP-FPM 8.1:**

   The default PHP version may not be 8.1. Use the Remi repository to install PHP 8.1:

   ```bash
   # Check current PHP version (if installed)
   php -v

   # If not 8.1, install Remi repository
   sudo dnf install epel-release -y
   sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm -y

   # Reset and enable PHP 8.1 module
   sudo dnf module reset php -y
   sudo dnf module enable php:remi-8.1 -y

   # Install PHP-FPM 8.1
   #sudo dnf install php-fpm php-cli -y
   sudo dnf install php-fpm php php-cli php-common php-mysqlnd php-gd php-xml php-mbstring php-pdo php-opcache -y

   # Verify version
   php -v
   ```

4. **Configure PHP-FPM:**

   Edit the PHP-FPM pool configuration file `/etc/php-fpm.d/www.conf`:

   ```bash
   sudo vi /etc/php-fpm.d/www.conf
   ```

   Find and modify the following lines:

   ```ini
   # Change the listen socket path
   # FROM: listen = /run/php-fpm/www.sock
   # TO:
   listen = /var/run/php-fpm/default.sock


   ;listen.owner = nginx
   ;listen.group = nginx
   ;listen.mode = 0660
   ```

Ensure the `/var/run/php-fpm/` directory exists:

```bash
sudo mkdir -p /var/run/php-fpm
sudo chown -R apache:apache /var/run/php-fpm
```

5. **Start and Enable Services:**

   ```bash
   # Start and enable PHP-FPM
   sudo systemctl start php-fpm
   sudo systemctl enable php-fpm

   # Start and enable Nginx
   sudo systemctl start nginx
   sudo systemctl enable nginx
   ```

````

6. **Verify Configuration:**

   ```bash
   # Check Nginx config syntax
   sudo nginx -t

   # Verify socket exists with correct permissions (should show nginx:nginx)
   ls -la /var/run/php-fpm/

   # Check services are running
   sudo systemctl status php-fpm
   sudo systemctl status nginx
   ```

7. **Test the Setup:**

   From the jump host, run:

   ```bash
   curl http://stapp02:8098/index.php
   curl http://stapp02:8098/info.php

   thor@jumphost ~$ curl http://stapp02:8098/index.php
Welcome to xFusionCorp Industries!
   ```

## Troubleshooting

If you encounter issues, check the Nginx error log:

```bash
sudo tail -20 /var/log/nginx/error.log
```
````
