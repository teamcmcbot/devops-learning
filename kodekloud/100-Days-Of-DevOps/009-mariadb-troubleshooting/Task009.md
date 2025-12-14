# Task 009: Troubleshoot MariaDB service not starting

Nautilus application could not connect to the database because MariaDB (`mariadb.service`) was down on the Nautilus DB server.

Goal: get `mariadb.service` back to `active (running)`.

## 1) Check service state

SSH to the DB server and confirm the symptom:

```bash
sudo systemctl status mariadb --no-pager
```

Observed: MariaDB was not running.

## 2) Attempt to start and read the real failure reason

Start MariaDB:

```bash
sudo systemctl start mariadb
```

If start fails, inspect the unit logs (root cause is usually here):

```bash
sudo journalctl -xeu mariadb.service --no-pager | tail -n 120
```

Observed key error during `ExecStartPre` (`mariadb-prepare-db-dir`):

```text
Database MariaDB is not initialized, but the directory /var/lib/mysql is not empty, so initialization cannot be done.
Make sure the /var/lib/mysql is empty before running mariadb-prepare-db-dir.
```

Note: messages like `PR_SET_MM_ARG_START failed: Operation not permitted` appeared in logs but were not the cause (common noise in containerized/systemd-in-container labs).

## 3) Confirm the configured datadir

Verify where MariaDB expects its data directory:

```bash
sudo mariadbd --verbose --help 2>/dev/null | awk '$1=="datadir"{print}'
sudo egrep -RIn "^\s*datadir\s*=" /etc/my.cnf /etc/my.cnf.d 2>/dev/null
```

Observed:

```text
datadir /var/lib/mysql/
/etc/my.cnf.d/mariadb-server.cnf:datadir=/var/lib/mysql
```

## 4) Validate the datadir exists

Check if the directory exists on the filesystem:

```bash
sudo ls -ld /var/lib/mysql
```

Observed: `/var/lib/mysql` did not exist.

## 5) Fix: create the missing datadir with correct ownership and permissions

Create the directory and set ownership/perms for the `mysql` service user:

```bash
sudo mkdir -p /var/lib/mysql
sudo chown -R mysql:mysql /var/lib/mysql
sudo chmod 750 /var/lib/mysql
```

Note: after `chmod 750`, a normal user may see `Permission denied` when listing the directory; `sudo ls -la /var/lib/mysql` will still work. This is expected.

## 6) Start MariaDB and verify

Start and validate:

```bash
sudo systemctl start mariadb
sudo systemctl status mariadb --no-pager
```

Expected:
- `Active: active (running)`
- `Status: "Taking your SQL requests now..."`

Optional functional checks:

```bash
sudo mysqladmin ping
sudo ss -ltnp | grep 3306
```

## Result

MariaDB is running again and the DB server is ready to accept connections.
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[1]: mariadb.service: Enqueued job mariadb.service/start as 492
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[1]: mariadb.service: Will spawn child (service_enter_start_pre): /usr/libexec/mariadb-check-socket
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[1]: mariadb.service: Failed to reset devices.allow/devices.deny: Operation not permitted
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[1]: mariadb.service: Failed to set 'trusted.invocation_id' xattr on control group /docker/dec850a036b1d07a61dc1cb3a49b0b5874384fd5747df3bee839625d63d8b1e3/system.slice/mariadb.service, ignoring: Operation not permitted
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[1]: mariadb.service: Failed to remove 'trusted.delegate' xattr flag on control group /docker/dec850a036b1d07a61dc1cb3a49b0b5874384fd5747df3bee839625d63d8b1e3/system.slice/mariadb.service, ignoring: Operation not permitted
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[1]: mariadb.service: About to execute /usr/libexec/mariadb-check-socket
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[1]: mariadb.service: Forked /usr/libexec/mariadb-check-socket as 3191
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[3191]: PR_SET_MM_ARG_START failed: Operation not permitted
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[1]: mariadb.service: Changed dead -> start-pre
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[1]: Starting MariaDB 10.5 database server...
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[1]: mariadb.service: User lookup succeeded: uid=27 gid=27
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[3191]: Bind-mounting / on /run/systemd/unit-root (MS_BIND|MS_REC "")...
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[3191]: Applying namespace mount on /run/systemd/unit-root/run/credentials
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[3191]: Bind-mounting /run/systemd/inaccessible/dir on /run/systemd/unit-root/run/credentials (MS_BIND|MS_REC "")...
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[3191]: Successfully mounted /run/systemd/inaccessible/dir to /run/systemd/unit-root/run/credentials
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[3191]: Applying namespace mount on /run/systemd/unit-root/run/systemd/incoming
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[3191]: Followed source symlinks /run/systemd/propagate/mariadb.service → /run/systemd/propagate/mariadb.service.
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[3191]: Bind-mounting /run/systemd/propagate/mariadb.service on /run/systemd/unit-root/run/systemd/incoming (MS_BIND "")...
```

## Task 009: Troubleshoot MariaDB service not starting

Nautilus application could not connect to the database because MariaDB (`mariadb.service`) was down on the Nautilus DB server.

Goal: get `mariadb.service` back to `active (running)`.

## 1) Check service state

SSH to the DB server and confirm the symptom:

```bash
sudo systemctl status mariadb --no-pager
```

Observed: `Active: inactive (dead)`.

## 2) Try starting it and capture the real error

Start MariaDB:

```bash
sudo systemctl start mariadb
```

If the start fails, inspect the unit logs (this is where the root cause shows up):

```bash
sudo journalctl -xeu mariadb.service --no-pager | tail -n 120
```

Observed failure was in `ExecStartPre` (`mariadb-prepare-db-dir`) and pointed to the configured datadir (`/var/lib/mysql`).

Note: messages like `PR_SET_MM_ARG_START failed: Operation not permitted` were present but not the cause (common noise in containerized/systemd-in-container labs).

## 3) Confirm the configured datadir

Verify where MariaDB expects its data directory:

```bash
sudo mariadbd --verbose --help 2>/dev/null | awk '$1=="datadir"{print}'
sudo egrep -RIn "^\s*datadir\s*=" /etc/my.cnf /etc/my.cnf.d 2>/dev/null
```

Observed:

```text
datadir /var/lib/mysql/
/etc/my.cnf.d/mariadb-server.cnf:datadir=/var/lib/mysql
```

## 4) Fix: create the missing datadir with correct ownership and permissions

The datadir path did not exist, so MariaDB could not initialize/start correctly.

Create the directory and set ownership/perms for the `mysql` service user:

```bash
sudo mkdir -p /var/lib/mysql
sudo chown -R mysql:mysql /var/lib/mysql
sudo chmod 750 /var/lib/mysql
```

Note: after `chmod 750`, a normal user may see `Permission denied` when listing the directory; `sudo ls -la /var/lib/mysql` will still work. This is expected.

## 5) Start MariaDB and verify

Start and validate:

```bash
sudo systemctl start mariadb
sudo systemctl status mariadb --no-pager
```

Expected:

- `Active: active (running)`
- `Status: "Taking your SQL requests now..."`

Optional functional checks:

```bash
sudo mysqladmin ping
sudo ss -ltnp | grep 3306
```

## Result

MariaDB is running again and the DB server is ready to accept connections.
Dec 14 04:09:55 stdb01.stratos.xfusioncorp.com systemd[3191]: Remounted /run/systemd/unit-root/run/systemd/incoming.
