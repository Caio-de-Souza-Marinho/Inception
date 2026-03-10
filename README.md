Readme · MD
*This project has been created as part of the 42 curriculum by caide-so.*

---

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to set up a small infrastructure composed of different services running inside Docker containers, orchestrated with Docker Compose, all inside a virtual machine. No pre-built images from Docker Hub are allowed (except for Alpine or Debian base images) — every service must be built from scratch using custom Dockerfiles.

### Project goal

The project enforces a deep understanding of containerization, networking, volumes, and service orchestration by requiring the student to manually configure each component of a web stack.

### Services included

**Mandatory:**
- **NGINX** — the sole entry point to the infrastructure, serving only over TLSv1.2/TLSv1.3 on port 443
- **WordPress + php-fpm** — the application layer, running without NGINX inside its own container
- **MariaDB** — the database backend for WordPress

**Bonus:**
- **Redis** — object cache for WordPress
- **FTP server** (vsftpd) — FTP access pointing to the WordPress volume
- **Adminer** — browser-based database management UI
- **Portainer** — browser-based Docker management dashboard
- **Static website** — a personal profile page served on port 80, independent of WordPress

### Design choices

All containers are based on `debian:bullseye`. Passwords are never hardcoded — they are injected at runtime via Docker secrets. Services communicate over a dedicated Docker bridge network named `inception`. Data is persisted using bind-mount volumes stored at `~/data/` on the host machine.

---

### Virtual Machines vs Docker

| | Virtual Machine | Docker |
|---|---|---|
| **Isolation** | Full OS-level isolation via hypervisor | Process-level isolation via kernel namespaces |
| **Size** | GBs — includes full OS image | MBs — shares host kernel |
| **Startup** | Minutes | Seconds |
| **Use case** | Running different OSes, strong security boundaries | Running isolated application processes efficiently |
| **Overhead** | High — emulates hardware | Low — no hardware emulation |

In this project, the VM is used as the host environment. Docker runs inside it, providing lightweight isolation for each service without the overhead of spinning up multiple full virtual machines.

---

### Secrets vs Environment Variables

| | Docker Secrets | Environment Variables |
|---|---|---|
| **Storage** | Stored as files in `/run/secrets/`, managed by Docker | Passed directly into the container environment |
| **Security** | Never exposed in `docker inspect`, logs, or child processes | Visible via `docker inspect` and in the process environment |
| **Best for** | Passwords, tokens, private keys | Non-sensitive config (hostnames, ports, usernames) |
| **Access** | Read from file inside container at runtime | Available as `$VAR` directly |

In this project, all passwords (MariaDB user password, root password, WordPress admin/user passwords, FTP password) are stored as secrets. Non-sensitive values like database name, usernames, and domain name are stored in `.env` and passed via `env_file`.

---

### Docker Network vs Host Network

| | Docker Bridge Network | Host Network |
|---|---|---|
| **Isolation** | Containers get their own virtual network, isolated from host | Container shares the host's network stack directly |
| **Communication** | Containers communicate via service name DNS resolution | Containers communicate on localhost |
| **Port exposure** | Explicit via `ports:` mapping | No mapping needed — binds directly to host ports |
| **Security** | Better — containers cannot access host network freely | Lower — full access to host interfaces |

In this project, all containers are connected to a custom bridge network named `inception`. Only NGINX exposes a port to the outside (443). Internal services (WordPress, MariaDB, Redis) are only reachable within the Docker network, not from the host or outside.

---

### Docker Volumes vs Bind Mounts

| | Docker Volumes | Bind Mounts |
|---|---|---|
| **Managed by** | Docker (stored in `/var/lib/docker/volumes/`) | The user (any host path) |
| **Portability** | High — Docker abstracts location | Low — depends on host directory structure |
| **Use case** | Production data persistence | Dev workflows, sharing specific host files |
| **Access from host** | Harder — requires `docker volume inspect` | Direct — it's just a normal directory |

In this project, bind mounts are used for both the MariaDB and WordPress volumes, pointing to `~/data/mariadb` and `~/data/wordpress` on the host. This satisfies the subject requirement that data must persist on the VM even if containers are stopped or removed, and allows easy inspection of data directly on the host.

---

## Instructions

### Prerequisites

- A Linux VM with Docker and Docker Compose installed
- Add `127.0.0.1 caide-so.42.fr` to `/etc/hosts` on the VM

### Setup

Clone the repository and navigate to the project root:

```bash
git clone  inception
cd inception
```

### Build and run

```bash
make
```

This will prompt you to enter passwords for MariaDB, WordPress, and FTP, then build all images and start all containers in detached mode.

### Other commands

```bash
make down      # Stop containers (keeps data)
make clean     # Stop containers and remove volumes
make fclean    # Full clean including host data directories
make re        # Full rebuild from scratch
```

### Accessing services

| Service | URL |
|---|---|
| WordPress | https://caide-so.42.fr |
| Static website | http://caide-so.42.fr |
| Adminer | http://caide-so.42.fr:8000/adminer.php |
| Portainer | http://caide-so.42.fr:9000 |
| FTP | `ftp caide-so.42.fr` (user: `ftpuser`) |

> **Note:** NGINX uses a self-signed SSL certificate, so your browser will show a security warning. Accept it to proceed.

---

## Resources

### Documentation

- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [Docker secrets documentation](https://docs.docker.com/engine/swarm/secrets/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [php-fpm documentation](https://www.php.net/manual/en/install.fpm.php)
- [Redis documentation](https://redis.io/docs/)
- [vsftpd documentation](http://vsftpd.beasts.org/vsftpd_conf.html)
- [Adminer](https://www.adminer.org/)
- [Portainer documentation](https://docs.portainer.io/)

### Articles & tutorials

- [Docker networking overview](https://docs.docker.com/network/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Understanding Docker volumes](https://docs.docker.com/storage/volumes/)
- [TLS/SSL with NGINX](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [WordPress Redis object cache plugin](https://wordpress.org/plugins/redis-cache/)

### AI usage

Claude (Anthropic) was used during this project for the following tasks:

- **Dockerfile structure** — getting the correct sequence of `apt install`, configuration steps, and entrypoint patterns for each service
- **Entrypoint scripting** — writing robust bash scripts with proper wait loops (e.g., waiting for MariaDB to be ready before WordPress setup), secret reading patterns, and conditional initialization logic
- **NGINX configuration** — TLS setup, FastCGI pass to php-fpm, and `try_files` routing
- **MariaDB initialization** — the SQL bootstrap sequence (create database, user, grant privileges, set root password) and the temporary backgrounded `mysqld` pattern
- **WordPress CLI commands** — the correct `wp-cli` command sequence for downloading core, creating config, installing, creating users, and enabling Redis cache
- **Redis and FTP configuration** — bind address settings, vsftpd passive mode configuration, and chroot setup
- **Bonus services** — Adminer PHP built-in server setup, Portainer binary installation and Docker socket mount
- **Static website** — HTML/CSS profile page design
- **README** — structure and content of this document

All generated code was reviewed, tested, and debugged manually on the VM.
