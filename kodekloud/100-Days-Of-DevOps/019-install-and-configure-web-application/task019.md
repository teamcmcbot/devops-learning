# Task 019 - Install and Configure Web Application

xFusionCorp Industries is planning to host two static websites on their infra in Stratos Datacenter. The development of these websites is still in-progress, but we want to get the servers ready. Please perform the following steps to accomplish the task:

a. Install `httpd` package and dependencies on `app server 3`.

b. Apache should serve on port `3004`.

c. There are two website's backups `/home/thor/ecommerce` and `/home/thor/demo` on `jump_host`. Set them up on Apache in a way that ecommerce should work on the link `http://localhost:3004/ecommerce/` and demo should work on link `http://localhost:3004/demo/` on the mentioned app server.

d. Once configured you should be able to access the website using curl command on the respective app server, i.e `curl http://localhost:3004/ecommerce/` and `curl http://localhost:3004/demo/`

## Solution Steps:

1. Install `httpd` package and dependencies on `stapp03`:

```bash
sudo dnf install httpd -y
```

2. Configure Apache to serve on port `3004` on `stapp03`:

```bash
cat /etc/httpd/conf/httpd.conf | grep Listen
sudo sed -i 's/Listen 80/Listen 3004/' /etc/httpd/conf/httpd.conf
cat /etc/httpd/conf/httpd.conf | grep Listen
sudo systemctl restart httpd
sudo systemctl enable httpd
# Verify Apache is listening on port 3004
sudo netstat -tulpen | grep 3004
sudo ss -tulpn | grep 3004
```

3. Copy the website directories from `jump_host` to `stapp03`:

```bash
# On jump_host - copy directories recursively
scp -r /home/thor/ecommerce banner@stapp03:/tmp/
scp -r /home/thor/demo banner@stapp03:/tmp/
```

4. Move directories to Apache document root on `stapp03`:

```bash
# On stapp03 (ssh banner@stapp03)
sudo mv /tmp/ecommerce /var/www/html/
sudo mv /tmp/demo /var/www/html/
```

> **Note on file ownership:**
>
> - For **static content**, `root:root` ownership is fine (and slightly more secure since Apache can only read, not write)
> - Use `apache:apache` ownership when the web application needs to **write** files (e.g., uploads, cache, logs)
> - Apache only needs **read** permission to serve static files, which root-owned files (typically `644`) provide
>
> Optional - change ownership to apache (not required for static sites):
>
> ```bash
> sudo chown -R apache:apache /var/www/html/ecommerce
> sudo chown -R apache:apache /var/www/html/demo
> ```

5. Verify the websites are accessible:

```bash
curl http://localhost:3004/ecommerce/
curl http://localhost:3004/demo/
```

```bash
[banner@stapp03 html]$ curl http://localhost:3004/ecommerce/
<!DOCTYPE html>
<html>
<body>

<h1>KodeKloud</h1>

<p>This is a sample page for our ecommerce website</p>

</body>
</html>[banner@stapp03 curl http://localhost:3004/demo/4/demo/
<!DOCTYPE html>
<html>
<body>

<h1>KodeKloud</h1>

<p>This is a sample page for our demo website</p>

</body>
</html>[banner@stapp03 html]$
```
