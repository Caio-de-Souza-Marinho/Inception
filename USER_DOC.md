# User Documentation — Inception

## What services are provided?

The Inception stack runs the following services:

| Service | What it does | Address |
|---|---|---|
| **WordPress** | The main website — a fully functional CMS | https://caide-so.42.fr |
| **Static website** | A personal profile page | http://caide-so.42.fr |
| **Adminer** | Database management UI (browser-based) | http://caide-so.42.fr:8888/adminer.php |
| **Portainer** | Docker dashboard — view and manage all containers | http://caide-so.42.fr:9000 |
| **FTP** | File access to the WordPress files | `ftp caide-so.42.fr` (port 21) |

The following services run in the background and are not directly user-facing:

- **MariaDB** — the database used by WordPress
- **Redis** — cache layer that speeds up WordPress
- **NGINX** — the web server that handles all incoming traffic and routes it to the right service

---

## Starting and stopping the project

Open a terminal on the VM and navigate to the project folder:

```bash
cd ~/inception
```

**Start everything:**
```bash
make
```
The first time you run this, you will be prompted to enter passwords for the database and WordPress accounts. After that, all containers will build and start automatically.

**Stop everything (keeps your data):**
```bash
make down
```

**Start again after stopping:**
```bash
make up
```

**Full restart from scratch** (rebuilds images, wipes all data):
```bash
make re
```

> ⚠️ `make re` deletes all WordPress content and database data. Only use it if you want a completely fresh start.

---

## Accessing the website and administration panels

### WordPress site
Open your browser and go to:
```
https://caide-so.42.fr
```
> Your browser will show a security warning because the SSL certificate is self-signed. Click **"Advanced"** → **"Accept the risk and continue"** (Firefox) or **"Proceed anyway"** (Chrome).

### WordPress admin panel
```
https://caide-so.42.fr/wp-admin
```
Log in with the WordPress admin credentials (see section below).

### Adminer (database UI)
```
http://caide-so.42.fr:8888/adminer.php
```
Use the following to log in:
- **System:** MySQL
- **Server:** `mariadb`
- **Username:** `root` or `wp_user`
- **Password:** your database password
- **Database:** `wordpress_db`

### Portainer (Docker dashboard)
```
http://caide-so.42.fr:9000
```
On the first visit, you will be asked to create an admin account. After that, click **"local"** to manage the running containers.

---

## Locating and managing credentials

All credentials are stored as plain text files inside the `secrets/` folder at the root of the project:

| File | What it contains |
|---|---|
| `secrets/db_password.txt` | MariaDB `wp_user` password |
| `secrets/db_root_password.txt` | MariaDB `root` password |
| `secrets/wp_admin_password.txt` | WordPress admin account password |
| `secrets/wp_user_password.txt` | WordPress regular user password |
| `secrets/ftp_password.txt` | FTP user password |

Non-sensitive configuration (usernames, database name, domain, email addresses) is stored in `srcs/.env`.

> ⚠️ The `secrets/` files are listed in `.gitignore` and are **never committed to the repository**. Keep them safe and do not share them.

**To change a password:** delete the relevant `.txt` file and run `make re`. You will be prompted to enter a new password.

---

## Checking that services are running correctly

**View all running containers:**
```bash
docker ps
```
You should see all containers listed with status `Up`.

**Check logs for a specific service:**
```bash
docker logs wordpress
docker logs mariadb
docker logs nginx
docker logs redis
docker logs ftp
docker logs adminer
docker logs portainer
```

**Using Portainer (easier):**
1. Go to `http://caide-so.42.fr:9000`
2. Click **"local"** → **"Containers"**
3. Click any container name → **"Logs"** to see its output in real time

**Quick health check — confirm WordPress is reachable:**
```bash
curl -k https://caide-so.42.fr
```
If you see HTML output, the stack is working correctly.
