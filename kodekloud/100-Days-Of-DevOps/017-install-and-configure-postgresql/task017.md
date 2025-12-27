# Task 017 - Install and Configure PostgreSQL

The Nautilus application development team has shared that they are planning to deploy one newly developed application on Nautilus infra in Stratos DC. The application uses PostgreSQL database, so as a pre-requisite we need to set up PostgreSQL database server as per requirements shared below:

PostgreSQL database server is already installed on the Nautilus database server.

a. Create a database user `kodekloud_joy` and set its password to `LQfKeWWxWD`.

b. Create a database `kodekloud_db1` and grant full permissions to user `kodekloud_joy` on this database.

Note: Please do not try to restart PostgreSQL server service.

## Solution

### 1. Connect to PostgreSQL as the postgres superuser

```bash
sudo -u postgres psql
```

### 2. Create the database user

```sql
CREATE USER kodekloud_joy WITH PASSWORD 'LQfKeWWxWD';
```

### 3. Create the database

```sql
CREATE DATABASE kodekloud_db1;
```

### 4. Grant full permissions to the user on the database

```sql
GRANT ALL PRIVILEGES ON DATABASE kodekloud_db1 TO kodekloud_joy;
```

### 5. Exit psql

```sql
\q
```

### One-liner alternative

You can also run these commands without entering the interactive shell:

```bash
sudo -u postgres psql -c "CREATE USER kodekloud_joy WITH PASSWORD 'LQfKeWWxWD';"
sudo -u postgres psql -c "CREATE DATABASE kodekloud_db1;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE kodekloud_db1 TO kodekloud_joy;"
```

### Verify the setup

```bash
# Check if user was created
sudo -u postgres psql -c "\du"

# Check if database was created
sudo -u postgres psql -c "\l"
```

```bash
[peter@stdb01 ~]$ sudo -u postgres psql -c "\du"
could not change directory to "/home/peter": Permission denied
                                     List of roles
   Role name   |                         Attributes                         | Member of
---------------+------------------------------------------------------------+-----------
 kodekloud_joy |                                                            | {}
 postgres      | Superuser, Create role, Create DB, Replication, Bypass RLS | {}

[peter@stdb01 ~]$ sudo -u postgres psql -c "\l"
could not change directory to "/home/peter": Permission denied
                                  List of databases
     Name      |  Owner   | Encoding  | Collate | Ctype |     Access privileges
---------------+----------+-----------+---------+-------+----------------------------
 kodekloud_db1 | postgres | SQL_ASCII | C       | C     | =Tc/postgres              +
               |          |           |         |       | postgres=CTc/postgres     +
               |          |           |         |       | kodekloud_joy=CTc/postgres
 postgres      | postgres | SQL_ASCII | C       | C     |
 template0     | postgres | SQL_ASCII | C       | C     | =c/postgres               +
               |          |           |         |       | postgres=CTc/postgres
 template1     | postgres | SQL_ASCII | C       | C     | =c/postgres               +
               |          |           |         |       | postgres=CTc/postgres
(4 rows)
```

## Connect to the database using the new user

```bash
[peter@stdb01 ~]$ psql -U kodekloud_joy -d kodekloud_db1 -h localhost
Password for user kodekloud_joy:
psql (13.14)
Type "help" for help.

kodekloud_db1=>
```

This confirms that the user `kodekloud_joy` can successfully connect to the database `kodekloud_db1`. The PostgreSQL server is now set up as per the requirements.
