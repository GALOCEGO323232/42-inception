# DEV_DOC — Developer Documentation

## Setting up the environment from scratch

### Prerequisites

- A Debian-based virtual machine
- Docker and Docker Compose installed
- `make` installed

If Docker is not installed, run the following on your VM:

```bash
sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg lsb-release make
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
```

Log out and back in after running `usermod`.

### Repository structure

```
inception/
├── Makefile
├── secrets/
│   ├── db_password.txt        ← NOT in Git
│   └── db_root_password.txt   ← NOT in Git
└── srcs/
    ├── .env                   ← NOT in Git
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── www.conf
        │   └── tools/
        │       └── wordpress.sh
        └── mariadb/
            ├── Dockerfile
            ├── conf/
            │   └── 50-server.cnf
            └── tools/
                └── mariadb.sh
```

### Configuration files

**1 — Create the secrets directory and files:**

```bash
mkdir -p secrets
echo "yourpassword" > secrets/db_password.txt
echo "yourrootpassword" > secrets/db_root_password.txt
```

**2 — Create the `.env` file:**

```bash
cat > srcs/.env << EOF
DOMAIN_NAME=kgagliar.42.fr

# MYSQL
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD_FILE=/run/secrets/db_password
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password

# WORDPRESS
WP_ADMIN_USER=kgagliar
WP_ADMIN_EMAIL=kgagliar@student.42.fr
WP_USER=wpeditor
WP_USER_EMAIL=wpeditor@student.42.fr
DB_HOST=mariadb
DB_PORT=3306
WP_ADMIN_PASSWORD_FILE=/run/secrets/db_password
WP_USER_PASSWORD_FILE=/run/secrets/db_password
EOF
```

## Building and launching the project

```bash
# Build images and start all containers
make

# Equivalent to:
cd srcs && docker compose up --build
```

The Makefile also automatically creates the data directories and adds the domain to `/etc/hosts`.

## Useful commands

### Container management

```bash
# See running containers
docker ps

# See all containers including stopped ones
docker ps -a

# See container logs
docker logs nginx
docker logs wordpress
docker logs mariadb

# Enter a container
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash

# Stop all containers
make down

# Rebuild everything from scratch
make re
```

### Volume management

```bash
# List volumes
docker volume ls

# Inspect a volume
docker volume inspect srcs_wordpress
docker volume inspect srcs_mariadb

# Data is stored on disk at:
ls /home/kgagliar/data/wordpress
ls /home/kgagliar/data/mariadb
```

### Network management

```bash
# List networks
docker network ls

# Inspect the inception network
docker network inspect srcs_inception
```

### Database access

To connect to the MariaDB database from inside the container:

```bash
docker exec -it mariadb bash
mariadb -u root -p
# Enter the root password from secrets/db_root_password.txt
```

Or connect as the WordPress user:

```bash
docker exec -it mariadb bash
mariadb -u wpuser -p wordpress
# Enter the password from secrets/db_password.txt
```

## Where data is stored and how it persists

All persistent data is stored on the host VM using bind-mount volumes:

```
/home/kgagliar/data/
├── wordpress/   ← WordPress files (themes, plugins, uploads)
└── mariadb/     ← MariaDB database files
```

These directories are mounted inside the containers at:

```
/var/www/wordpress  ← inside the wordpress and nginx containers
/var/lib/mysql      ← inside the mariadb container
```

Data persists across container restarts and even VM reboots because it lives on the host filesystem. The only way to delete the data is to run `make fclean`, which removes the `/home/kgagliar/data/` directory entirely.

When the containers start for the first time with an empty data directory, the initialization scripts run automatically to set up the database and install WordPress. On subsequent starts, the scripts detect existing data and skip the initialization.
