# Developer Documentation — Inception

## Prerequisites

Before setting up the project, make sure the following are installed on your VM:

```bash
# Check Docker
docker --version

# Check Docker Compose
docker compose version
```

If Docker is not installed:
```bash
sudo apt update && sudo apt install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER   # Allow running docker without sudo
newgrp docker                   # Apply group change without logging out
```

Also add the domain to `/etc/hosts`:
```bash
echo "127.0.0.1 caide-so.42.fr" | sudo tee -a /etc/hosts
```

---

## Project structure

```
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/                        # Runtime credentials (gitignored)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   ├── wp_user_password.txt
│   └── ftp_password.txt
└── srcs/
    ├── .env                        # Non-sensitive configuration
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   └── tools/entrypoint.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/nginx.conf
        │   └── tools/entrypoint.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/entrypoint.sh
        └── bonus/
            ├── redis/
            │   ├── Dockerfile
            │   └── tools/entrypoint.sh
            ├── ftp/
            │   ├── Dockerfile
            │   ├── conf/vsftpd.conf
            │   └── tools/entrypoint.sh
            ├── adminer/
            │   ├── Dockerfile
            │   └── tools/entrypoint.sh
            ├── portainer/
            │   └── Dockerfile
            └── website/
                ├── Dockerfile
                ├── conf/nginx.conf
                └── www/index.html
```

---

## Configuration files

### `srcs/.env`

Contains non-sensitive environment variables passed to containers:

```env
DOMAIN_NAME=caide-so.42.fr

MYSQL_DATABASE=wordpress_db
MYSQL_USER=wp_user

WP_ADMIN_USER=caio
WP_ADMIN_EMAIL=caiosouzamarinho@gmail.com

WP_USER=caide-so
WP_USER_EMAIL=caide-so@student.42sp.org.br

REDIS_HOST=redis
REDIS_PORT=6379

FTP_USER=ftpuser
```

### `secrets/`

These files are created interactively by the Makefile on first run. Each file contains a single password as plain text. They are mounted into containers at `/run/secrets/<name>` and read by entrypoint scripts using:

```bash
PASSWORD=$(cat /run/secrets/secret_name)
```

---

## Building and launching the project

### First run

```bash
cd ~/inception
make
```

The Makefile will:
1. Detect missing secret files and prompt you to enter passwords interactively
2. Create `~/data/mariadb` and `~/data/wordpress` directories on the host
3. Run `docker compose up --build -d` to build all images and start all containers

### Makefile targets

| Target | Description |
|---|---|
| `make` / `make up` | Build images and start all containers |
| `make down` | Stop and remove containers (volumes and data preserved) |
| `make clean` | Stop containers and remove Docker volumes |
| `make fclean` | Full clean: removes containers, volumes, and `~/data/` on the host |
| `make re` | `fclean` followed by `up` — complete rebuild from scratch |

---

## Managing containers

**List running containers:**
```bash
docker ps
```

**List all containers (including stopped):**
```bash
docker ps -a
```

**View logs:**
```bash
docker logs 
docker logs -f    # Follow live output
```

**Open a shell inside a container:**
```bash
docker exec -it  bash
```

**Restart a single container:**
```bash
docker restart 
```

**Rebuild and restart a single service without touching others:**
```bash
docker compose -f srcs/docker-compose.yml up --build -d 
```

**Remove all stopped containers, unused images and build cache:**
```bash
make fclean && docker system prune -af
```

---

## Managing volumes

Volumes are defined in `docker-compose.yml` as bind mounts:

| Volume | Host path | Purpose |
|---|---|---|
| `mariadb` | `~/data/mariadb` | MariaDB database files |
| `wordpress` | `~/data/wordpress` | WordPress files (core, themes, plugins, uploads) |
| `portainer_data` | Docker-managed | Portainer configuration and state |

**Inspect volume content:**
```bash
ls ~/data/mariadb
ls ~/data/wordpress
```

**Data persistence:** data in `~/data/` survives `make down` and `make clean`. Only `make fclean` and `make re` delete it by running `sudo rm -rf ~/data`.

---

## Where data is stored and how it persists

| Data | Location | Survives `make down`? | Survives `make fclean`? |
|---|---|---|---|
| WordPress files & uploads | `~/data/wordpress/` | ✅ Yes | ❌ No |
| MariaDB database | `~/data/mariadb/` | ✅ Yes | ❌ No |
| Secrets (passwords) | `~/inception/secrets/*.txt` | ✅ Yes | ❌ No (deleted by fclean) |
| Portainer state | Docker-managed volume | ✅ Yes | ❌ No |
| Docker images | Local Docker image cache | ✅ Yes | ❌ No (pruned manually) |

### How persistence works

WordPress and MariaDB entrypoints check whether data already exists before initializing:

- **MariaDB:** checks for `/var/lib/mysql/${MYSQL_DATABASE}` — if it exists, skips initialization and starts the server directly
- **WordPress:** checks for `/var/www/html/wp-config.php` — if it exists, skips download and setup and starts php-fpm directly

This means you can safely run `make down` and `make up` without losing any data.

---

## Useful debugging commands

**Check if NGINX is serving correctly:**
```bash
curl -k https://caide-so.42.fr
```

**Test MariaDB connection from inside the WordPress container:**
```bash
docker exec -it wordpress bash
mysqladmin ping -h mariadb -u wp_user -p
```

**Check Redis is caching:**
```bash
docker exec -it redis redis-cli ping
# Expected output: PONG
```

**Check FTP is accessible:**
```bash
ftp caide-so.42.fr
# Login with ftpuser and your ftp password
# Type: passive
# Type: ls
```

**Inspect the Docker network:**
```bash
docker network inspect inception
```
