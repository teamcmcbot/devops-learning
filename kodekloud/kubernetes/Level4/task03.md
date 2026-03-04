# Task 03:

The Nautilus Application Development team is planning to deploy one of the php-based applications on Kubernetes cluster. As per the recent discussion with DevOps team, they have decided to use nginx and phpfpm. Additionally, they also shared some custom configuration requirements. Below you can find more details. Please complete this task as per requirements mentioned below:



1) Create a service to expose this app, the service type must be `NodePort`, nodePort should be `30012`.


2) Create a config map named `nginx-config` for `nginx.conf` as we want to add some custom settings in nginx.conf.


a) Change the default port `80` to `8099` in `nginx.conf`.


b) Change the default document root `/usr/share/nginx` to `/var/www/html` in `nginx.conf`.


c) Update the directory index to `index  index.html index.htm index.php` in `nginx.conf`.


3) Create a pod named `nginx-phpfpm` .


b) Create a shared volume named `shared-files` that will be used by both containers (nginx and phpfpm) also it should be a `emptyDir` volume.


c) Map the ConfigMap we declared above as a volume for nginx container. Name the volume as `nginx-config-volume`, mount path should be `/etc/nginx/nginx`.conf and `subPath` should be `nginx.conf`


d) Nginx container should be named as `nginx-container` and it should use `nginx:latest` image. PhpFPM container should be named as `php-fpm-container` and it should use `php:8.1-fpm-alpine` image.


e) The shared volume `shared-files` should be mounted at `/var/www/html` location in both containers. Copy `/opt/index.php` from `jump host` to the nginx document root inside the `nginx` container, once done you can access the app using `App` button on the top bar.


Before clicking on `finish` button always make sure to check if all pods are in `running` state.


You can use any labels as per your choice.


Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.


## Solution:

1. Create a temp nginx pod to retrieve the default nginx.conf

```bash
thor@jumphost ~$ k run temp-nginx --image=nginx:latest
pod/temp-nginx created

thor@jumphost ~$ k exec -it temp-nginx -- ls -lrtR /etc/nginx
/etc/nginx:
total 32
-rw-r--r-- 1 root root  664 Feb  4 15:12 uwsgi_params
-rw-r--r-- 1 root root  636 Feb  4 15:12 scgi_params
-rw-r--r-- 1 root root 5349 Feb  4 15:12 mime.types
-rw-r--r-- 1 root root 1007 Feb  4 15:12 fastcgi_params
-rw-r--r-- 1 root root  644 Feb  4 20:12 nginx.conf
lrwxrwxrwx 1 root root   22 Feb  4 20:12 modules -> /usr/lib/nginx/modules
drwxr-xr-x 1 root root 4096 Mar  4 05:33 conf.d

/etc/nginx/conf.d:
total 4
```

Copy nginx.conf + default.conf:

```bash
thor@jumphost ~$ k cp temp-nginx:etc/nginx/nginx.conf ~/nginx.conf
thor@jumphost ~$ ls
nginx.conf
thor@jumphost ~$ k cp temp-nginx:etc/nginx/conf.d/default.conf ~/default.conf
thor@jumphost ~$ ls
default.conf  nginx.conf
```

nginx.conf:

```conf
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
```

default.conf
```conf
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    #location ~ \.php$ {
    #    root           html;
    #    fastcgi_pass   127.0.0.1:9000;
    #    fastcgi_index  index.php;
    #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    #    include        fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}
```

**NOTE: ** notice `include /etc/nginx/conf.d/*.conf;` in nginx.conf which contains the server section which we are editing.

Combine them into 1 file:

```conf
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    #location ~ \.php$ {
    #    root           html;
    #    fastcgi_pass   127.0.0.1:9000;
    #    fastcgi_index  index.php;
    #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    #    include        fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}
}
```

2. Update nginx.conf with changes from 2a, 2b, 2c.

Additionally, uncomment the PHP-FPM location block and fix the pfp file location.

```conf
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    server {
    listen       8099;
    listen  [::]:8099;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /var/www/html;
        index  index  index.html index.htm index.php;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    location ~ \.php$ {
        root           /var/www/html;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}
}
```

3. Create a config map named `nginx-config` for `nginx.conf`

```bash
thor@jumphost ~$ k create cm nginx-config --from-file=nginx.conf
configmap/nginx-config created
thor@jumphost ~$ k describe configmap/nginx-config
Name:         nginx-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
nginx.conf:
----

user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    server {
    listen       8099;
    listen  [::]:8099;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /var/www/html;
        index  index  index.html index.htm index.php;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    location ~ \.php$ {
        root           /var/www/html;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}
}


BinaryData
====

Events:  <none>
```


4. Create deployment yaml:

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx-phpfpm
  name: nginx-phpfpm
spec:
  volumes:
  - name: shared-files
    emptyDir: {}
  - name: nginx-config-volume
    configMap:
      # Provide the name of the ConfigMap containing the files you want
      # to add to the container
      name: nginx-config
  containers:
  - image: nginx:latest
    name: nginx-container
    resources: {}
    volumeMounts:
    - name: shared-files
      mountPath: /var/www/html
    - name: nginx-config-volume
      mountPath: /etc/nginx/nginx.conf
      subPath: nginx.conf
  - image: php:8.3-fpm-alpine
    name: php-fpm-container
    resources: {}
    volumeMounts:
    - name: shared-files
      mountPath: /var/www/html
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

5. Copy `/opt/index.php` from jump host to container.

```bash
thor@jumphost ~$ k cp /opt/index.php nginx-phpfpm:var/www/html/index.php -c nginx-container
thor@jumphost ~$ k exec -it nginx-phpfpm -c nginx-container -- cat /var/www/html/index.php
It works!thor@jumphost ~$ k exec -it nginx-phpfpm -c php-fpm-container -- cat /var/www/html/index.php
It works!thor@jumphost ~$ 
```

6. Create NodePort service:

```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    run: nginx-phpfpm
  name: nginx-service
spec:
  ports:
  - port: 8099
    protocol: TCP
    targetPort: 8099
    nodePort: 30012
  selector:
    run: nginx-phpfpm
  type: NodePort
status:
  loadBalancer: {}
```

## Verification:

```bash
thor@jumphost ~$ k get nodes
NAME                      STATUS   ROLES           AGE   VERSION
kodekloud-control-plane   Ready    control-plane   45m   v1.27.16-1+f5da3b717fc217

thor@jumphost ~$ k get all
NAME               READY   STATUS    RESTARTS   AGE
pod/nginx-phpfpm   2/2     Running   0          7m2s
pod/temp-nginx     1/1     Running   0          29m

NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/kubernetes      ClusterIP   10.96.0.1       <none>        443/TCP          45m
service/nginx-service   NodePort    10.96.204.208   <none>        8099:30012/TCP   41s

thor@jumphost ~$ curl http://kodekloud-control-plane:30012
It works!

```