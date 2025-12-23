# Task 013: iptables installation and configuration

We have one of our websites up and running on our Nautilus infrastructure in Stratos DC. Our security team has raised a concern that right now Apache’s port i.e 8083 is open for all since there is no firewall installed on these hosts. So we have decided to add some security layer for these hosts and after discussions and recommendations we have come up with the following requirements:

1. Install `iptables` and all its dependencies on each app host.

2. Block incoming port 8083 on all apps for everyone except for LBR host.

3. Make sure the rules remain, even after system reboot.

## App Hosts:

- app1: tony@stapp01
- app2: steve@stapp02
- app3: banner@stapp03

## Load Balancer Host:

- loki@stlb01

## iptables commands

- To list all rules: `sudo iptables -L -n -v`
- To save iptables rules: `sudo service iptables save`
- To restart iptables service: `sudo systemctl restart iptables`

## Solution Steps

1. **Install iptables** on each app host (app1 and app2):

   ```bash
   sudo dnf install -y iptables iptables-services
   sudo systemctl enable --now iptables
   ```

2. List current iptables rules to understand existing configurations:

```bash
[tony@stapp01 ~]$ sudo iptables -L INPUT -n --line-numbers
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
2    ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0
3    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
4    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:22
5    REJECT     all  --  0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited
[tony@stapp01 ~]$


[steve@stapp02 ~]$ sudo iptables -L INPUT -n --line-numbers
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
2    ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0
3    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
4    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:22
5    REJECT     all  --  0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited
[steve@stapp02 ~]$

[banner@stapp03 ~]$ sudo iptables -L INPUT -n --line-numbers
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
2    ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0
3    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
4    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:22
5    REJECT     all  --  0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited
[banner@stapp03 ~]$
```

**Note:** There is a default REJECT rule at the end of the INPUT chain at line number 5.

3. **Add rule to allow traffic from LBR host (stlb01) to port 8083** on each app host:

   ```bash
    # Get the IP address of the LBR host
    [banner@stapp03 ~]$ getent hosts stlb01
    172.16.238.14   stlb01

   # Insert the allow rule before the final catch-all REJECT (line 5 in the examples above)
   sudo iptables -I INPUT 5 -p tcp -s 172.16.238.14 --dport 8083 -m conntrack --ctstate NEW -j ACCEPT
   ```

   Use the LBR **IP address** (recommended). Hostnames can be used, but they are resolved to an IP only at rule creation time and won't automatically update later.

```bash
[tony@stapp01 ~]$ sudo iptables -I INPUT 5 -p tcp -s 172.16.238.14 --dport 8083 -m conntrack --ctstate NEW -j ACCEPT
[tony@stapp01 ~]$ sudo iptables -L INPUT -n --line-numbers
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
2    ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0
3    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
4    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:22
5    ACCEPT     tcp  --  172.16.238.14        0.0.0.0/0            tcp dpt:8083 ctstate NEW
6    REJECT     all  --  0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited
[tony@stapp01 ~]$ sudo iptables -L INPUT -n -v --line-numbers | grep 8083
5        0     0 ACCEPT     tcp  --  *      *       172.16.238.14        0.0.0.0/0            tcp dpt:8083 ctstate NEW
[tony@stapp01 ~]$


sudo iptables -I INPUT 5 -p tcp -s 172.16.238.14 --dport 8083 -m conntrack --ctstate NEW -j ACCEPT
[sudo] password for steve:
[steve@stapp02 ~]$ sudo iptables -L INPUT -n --line-numbers
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
2    ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0
3    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
4    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:22
5    ACCEPT     tcp  --  172.16.238.14        0.0.0.0/0            tcp dpt:8083 ctstate NEW
6    REJECT     all  --  0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited
[steve@stapp02 ~]$ sudo iptables -L INPUT -n -v --line-numbers | grep 8083
5        0     0 ACCEPT     tcp  --  *      *       172.16.238.14        0.0.0.0/0            tcp dpt:8083 ctstate NEW
[steve@stapp02 ~]$


[banner@stapp03 ~]$ sudo iptables -I INPUT 5 -p tcp -s 172.16.238.14 --dport 8083 -m conntrack --ctstate NEW -j ACCEPT
[sudo] password for banner:
[banner@stapp03 ~]$ sudo iptables -L INPUT -n --line-numbers
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
2    ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0
3    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
4    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:22
5    ACCEPT     tcp  --  172.16.238.14        0.0.0.0/0            tcp dpt:8083 ctstate NEW
6    REJECT     all  --  0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited
[banner@stapp03 ~]$ sudo iptables -L INPUT -n -v --line-numbers | grep 8083
5        0     0 ACCEPT     tcp  --  *      *       172.16.238.14        0.0.0.0/0            tcp dpt:8083 ctstate NEW
[banner@stapp03 ~]$
```

4. **Save the iptables rules** to ensure they persist after a reboot on each app host:

   ```bash
   sudo service iptables save
   sudo systemctl restart iptables
   ```

```bash

```

5. Verfication:

- From Jump Host (stjump01), try to access port 8083 on app hosts (should be blocked):

  ```bash
  thor@jumphost ~$ nc -vz stapp01 8083
  Ncat: Version 7.92 ( https://nmap.org/ncat )
  Ncat: No route to host.
  ```

- From LBR host (stlb01), try to access port 8083 on app hosts (should be allowed):

  ```bash
  [loki@stlb01 ~]$ nc -vz stapp01 8083
  Ncat: Version 7.92 ( https://nmap.org/ncat )
  Ncat: Connected to 172.16.238.10:8083.
  Ncat: 0 bytes sent, 0 bytes received in 0.02 seconds.
  [loki@stlb01 ~]$


[loki@stlb01 ~]$ curl http://stapp01:8083 | head -n 10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
<html lang="en-US" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US">
<head>
  <meta name="generator" content="HTML Tidy for HTML5 for Linux version 5.8.0" />
  <title>HTTP Server Test Page</title>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
  <link rel="shortcut icon" type="image/png" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAAlwSFlzAAABYwAAAWMBjWAytwAAAUdQTFRFR3BMrpC4xa2SxcOY0eeb2qyj19iB9tWY0q3JmZm/m6Wd49WAnIm1QUCIrWab+eS64sjavLzWs7HP2+yzsa/O3e61+uCx4O+++t+vtLTQ3cDV3sHX8bNBqNNEqtNH8bI/rKzM2+2w2uyv+uCz+uG19OPF+OjD6dTf49Hh58103sPY6LmDs5q+3ratiXus396RlIeazNh25e/J5dmN5/DG273UzLSerMSDqLOpxcLZxcbWzcumwqKlr4iz6eq339C/6c7K6+7Q8unO59jh3t3Dqpe9xbzV0b/W09Ldw8rF7uazoU+M76cknM0qJiV39ch2xJG3weB6eHeqw4+2xZO4v950xOF/9cp89cZw87tYWViXeXmrdXWprWWarGSauHmo8bI/87xZ8bE+qNNFuHinsthbqdRGs9lct3emQUCIV1aWQ0KJtNld5X6kagAAAEt0Uk5TANbc3Krb2aqqqtvZ1vv7fX19lJaWlJR9lpyWlPv8+/yWjpaWm8/P0dLsle3l5erl7uzQ5dGP5e3lzs7l7url5+ejoqLn5eTko+bklAXz+AAAAMpJREFUGNNjYIAAMQkGFKAsI68C54izsJjoa2rrqnNwCIAFWHwDk33ZWL1jA7w5IAKBqWEggZD4AIiAUVpoehgba0hKcJwGiK9l7esbmmPnkBHs7a0jycAgxWfDzMzs4ujszsjIqMcrxCDNZ8vDw+Pm4WTPxMRkwCvCwGDq6ucXHeXpFRnu42OmADLEMjs6KoaLOyIyPEkVbAtnUFaMHxe3T0SiPztEwC8oEySQ4O8DERDk5LSyMDc0VmNn54f7R1FOVgnVu8KiUAYAknghR8FpTgsAAAAASUVORK5CYII=" />
  <style type="text/css">
    /*<![CDATA[*/
  2 2650k    2 75031    0     0  71.5M      0 --:--:-- --:--:-- --:--:-- 71.5M
curl: (23) Failure writing output to destination
[loki@stlb01 ~]$ curl http://stapp02:8083 | head -n 10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
<html lang="en-US" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US">
<head>
  <meta name="generator" content="HTML Tidy for HTML5 for Linux version 5.8.0" />
  <title>HTTP Server Test Page</title>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
  <link rel="shortcut icon" type="image/png" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAAlwSFlzAAABYwAAAWMBjWAytwAAAUdQTFRFR3BMrpC4xa2SxcOY0eeb2qyj19iB9tWY0q3JmZm/m6Wd49WAnIm1QUCIrWab+eS64sjavLzWs7HP2+yzsa/O3e61+uCx4O+++t+vtLTQ3cDV3sHX8bNBqNNEqtNH8bI/rKzM2+2w2uyv+uCz+uG19OPF+OjD6dTf49Hh58103sPY6LmDs5q+3ratiXus396RlIeazNh25e/J5dmN5/DG273UzLSerMSDqLOpxcLZxcbWzcumwqKlr4iz6eq339C/6c7K6+7Q8unO59jh3t3Dqpe9xbzV0b/W09Ldw8rF7uazoU+M76cknM0qJiV39ch2xJG3weB6eHeqw4+2xZO4v950xOF/9cp89cZw87tYWViXeXmrdXWprWWarGSauHmo8bI/87xZ8bE+qNNFuHinsthbqdRGs9lct3emQUCIV1aWQ0KJtNld5X6kagAAAEt0Uk5TANbc3Krb2aqqqtvZ1vv7fX19lJaWlJR9lpyWlPv8+/yWjpaWm8/P0dLsle3l5erl7uzQ5dGP5e3lzs7l7url5+ejoqLn5eTko+bklAXz+AAAAMpJREFUGNNjYIAAMQkGFKAsI68C54izsJjoa2rrqnNwCIAFWHwDk33ZWL1jA7w5IAKBqWEggZD4AIiAUVpoehgba0hKcJwGiK9l7esbmmPnkBHs7a0jycAgxWfDzMzs4ujszsjIqMcrxCDNZ8vDw+Pm4WTPxMRkwCvCwGDq6ucXHeXpFRnu42OmADLEMjs6KoaLOyIyPEkVbAtnUFaMHxe3T0SiPztEwC8oEySQ4O8DERDk5LSyMDc0VmNn54f7R1FOVgnVu8KiUAYAknghR8FpTgsAAAAASUVORK5CYII=" />
  <style type="text/css">
    /*<![CDATA[*/
  4 2650k    4  125k    0     0  61.3M      0 --:--:-- --:--:-- --:--:-- 61.3M
curl: (23) Failure writing output to destination
[loki@stlb01 ~]$ curl http://stapp03:8083 | head -n 10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
<html lang="en-US" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US">
<head>
  <meta name="generator" content="HTML Tidy for HTML5 for Linux version 5.8.0" />
  <title>HTTP Server Test Page</title>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
  <link rel="shortcut icon" type="image/png" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAAlwSFlzAAABYwAAAWMBjWAytwAAAUdQTFRFR3BMrpC4xa2SxcOY0eeb2qyj19iB9tWY0q3JmZm/m6Wd49WAnIm1QUCIrWab+eS64sjavLzWs7HP2+yzsa/O3e61+uCx4O+++t+vtLTQ3cDV3sHX8bNBqNNEqtNH8bI/rKzM2+2w2uyv+uCz+uG19OPF+OjD6dTf49Hh58103sPY6LmDs5q+3ratiXus396RlIeazNh25e/J5dmN5/DG273UzLSerMSDqLOpxcLZxcbWzcumwqKlr4iz6eq339C/6c7K6+7Q8unO59jh3t3Dqpe9xbzV0b/W09Ldw8rF7uazoU+M76cknM0qJiV39ch2xJG3weB6eHeqw4+2xZO4v950xOF/9cp89cZw87tYWViXeXmrdXWprWWarGSauHmo8bI/87xZ8bE+qNNFuHinsthbqdRGs9lct3emQUCIV1aWQ0KJtNld5X6kagAAAEt0Uk5TANbc3Krb2aqqqtvZ1vv7fX19lJaWlJR9lpyWlPv8+/yWjpaWm8/P0dLsle3l5erl7uzQ5dGP5e3lzs7l7url5+ejoqLn5eTko+bklAXz+AAAAMpJREFUGNNjYIAAMQkGFKAsI68C54izsJjoa2rrqnNwCIAFWHwDk33ZWL1jA7w5IAKBqWEggZD4AIiAUVpoehgba0hKcJwGiK9l7esbmmPnkBHs7a0jycAgxWfDzMzs4ujszsjIqMcrxCDNZ8vDw+Pm4WTPxMRkwCvCwGDq6ucXHeXpFRnu42OmADLEMjs6KoaLOyIyPEkVbAtnUFaMHxe3T0SiPztEwC8oEySQ4O8DERDk5LSyMDc0VmNn54f7R1FOVgnVu8KiUAYAknghR8FpTgsAAAAASUVORK5CYII=" />
  <style type="text/css">
    /*<![CDATA[*/
  4 2650k    4  111k    0     0  54.4M      0 --:--:-- --:--:-- --:--:-- 54.4M
curl: (23) Failure writing output to destination

  ```
