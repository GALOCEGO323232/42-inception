*This project has been created as part of the 42 curriculum by kgagliar.*

# Inception

## Description

Inception is a System Administration project from the 42 curriculum. The goal is to set up a small but complete web infrastructure using Docker and Docker Compose inside a virtual machine. The infrastructure consists of three services — NGINX, WordPress with PHP-FPM, and MariaDB — each running in its own dedicated container and communicating through a private Docker network.

The project enforces best practices around containerization, security (TLS, secrets, environment variables), and data persistence through Docker volumes.

## Project Description

### Use of Docker

Docker is used to containerize each service independently. Each service has its own `Dockerfile` that builds a custom image from `debian:bookworm`. Docker Compose orchestrates all three containers, defining how they communicate, which volumes they use, and how secrets are injected.

The Dockerfiles are called by the `docker-compose.yml`, which is itself called by the `Makefile`. No pre-built images from DockerHub are used — every image is built from scratch.

### Design Choices

**Services included:**
- NGINX — acts as the sole entry point, handling HTTPS with TLSv1.2/TLSv1.3
- WordPress + PHP-FPM — processes the website's PHP and serves its content
- MariaDB — stores all WordPress data persistently

### Virtual Machines vs Docker

| Virtual Machines | Docker |
|---|---|
| Each VM has its own full OS and kernel | Containers share the host kernel |
| Heavy — gigabytes of disk, slow to start | Lightweight — megabytes, starts in seconds |
| Strong isolation between VMs | Process-level isolation via namespaces |
| Best for running different OSes | Best for packaging and running applications |

Docker containers are not VMs. They share the host kernel and only isolate the filesystem, processes, and network. This makes them much faster and lighter than full virtual machines.

### Secrets vs Environment Variables

| Secrets | Environment Variables |
|---|---|
| Stored as files in `/run/secrets/` | Stored in memory, visible via `printenv` |
| Restricted file permissions | Any process in the container can read them |
| Not stored in the image layers | Can leak through Docker inspect or logs |
| Used for passwords and sensitive data | Used for configuration (domain, usernames) |

In this project, passwords are stored as Docker secrets (in the `secrets/` folder), while non-sensitive configuration like domain name and usernames are stored in the `.env` file.

### Docker Network vs Host Network

| Docker Network (bridge) | Host Network |
|---|---|
| Containers get their own isolated network | Container shares the host's network stack |
| Containers communicate by service name | No network isolation |
| Only exposed ports are accessible | All ports are accessible |
| Recommended for security | Forbidden in this project |

This project uses a custom bridge network called `inception`. Only the NGINX container exposes a port (443) to the outside world. WordPress and MariaDB are only accessible within the internal network.

### Docker Volumes vs Bind Mounts

| Docker Volumes | Bind Mounts |
|---|---|
| Managed by Docker | Mapped directly to a host path |
| Data survives container removal | Data survives container removal |
| Less explicit path control | Explicit control over the host path |

This project uses bind-mount-style volumes with `driver_opts` to store data in `/home/kgagliar/data/`. This ensures the data is stored in a predictable, inspectable location on the host machine, as required by the subject.

## Instructions

### Prerequisites

- Docker and Docker Compose installed on the VM
- `make` installed
- The `secrets/` files and `srcs/.env` created before running (see DEV_DOC.md)

### Running the project

```bash
# Clone the repository
git clone <repo_url>
cd inception

# Create secrets
echo "yourpassword" > secrets/db_password.txt
echo "yourrootpassword" > secrets/db_root_password.txt

# Fill in the .env file
cp srcs/.env.example srcs/.env
# Edit srcs/.env with your values

# Build and start everything
make
```

### Stopping the project

```bash
make down    # stops containers, keeps data
make clean   # stops containers and removes volumes
make fclean  # removes everything including data
make re      # full rebuild from scratch
```

### Accessing the site

Open your browser and go to:
```
https://kgagliar.42.fr
```

Admin panel:
```
https://kgagliar.42.fr/wp-admin
```

## Resources

### Official Documentation

- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [WordPress CLI documentation](https://wp-cli.org/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)
- [OpenSSL documentation](https://www.openssl.org/docs/)
- [TLS 1.3 RFC](https://www.rfc-editor.org/rfc/rfc8446)

### Video References

- [Docker Tutorial](https://www.youtube.com/watch?v=D_ha0g9yS2E&t=5s)
- [Docker Compose Tutorial](https://www.youtube.com/watch?v=gd_cUmwzgEM)
- [NGINX Tutorial](https://www.youtube.com/watch?v=Y6kz884AoME)
- [WordPress with Docker](https://www.youtube.com/watch?v=ntbpIfS44Gw&t=685s)
- [MariaDB with Docker](https://www.youtube.com/watch?v=DdoncfOdru8)

### AI Usage

- **Understanding concepts**: Docker, TLS/SSL, PHP-FPM, MariaDB configuration, shell scripting
- **Guidance on structure**: Directory layout, Dockerfile best practices, docker-compose.yml syntax

All code was written and understood by the student — AI was used as a teacher, not as a code generator.
