# USER_DOC — User Documentation

## What services are provided?

The Inception stack provides a complete WordPress website accessible via HTTPS. It consists of three services:

| Service | What it does |
|---|---|
| **NGINX** | Receives all incoming HTTPS requests on port 443 and routes them to WordPress |
| **WordPress + PHP-FPM** | Runs the WordPress website and processes all PHP code |
| **MariaDB** | Stores all WordPress data (posts, users, settings) |

Only NGINX is accessible from outside — WordPress and MariaDB communicate internally and are never directly exposed to the internet.

## Starting the project

Before starting for the first time, make sure you have created the required files:

```bash
# Create the secrets folder and password files
echo "yourpassword" > secrets/db_password.txt
echo "yourrootpassword" > secrets/db_root_password.txt

# Make sure srcs/.env is filled in correctly
cat srcs/.env
```

Then start everything with:

```bash
make
```

This will automatically create the data folders, configure the domain in `/etc/hosts`, build the Docker images, and start all containers.

## Stopping the project

```bash
make down    # stops all containers (data is preserved)
make clean   # stops containers and removes Docker volumes (data is preserved on disk)
make fclean  # removes everything including data on disk
make re      # full rebuild from scratch
```

## Accessing the website

Once the containers are running, open your browser and go to:

```
https://kgagliar.42.fr
```

You will see a security warning because the TLS certificate is self-signed. This is expected — click "Advanced" and proceed to the site.

### Accessing the administration panel

```
https://kgagliar.42.fr/wp-admin
```

Log in with the administrator credentials defined in `srcs/.env`:
- **Username**: the value of `WP_ADMIN_USER`
- **Password**: the content of `secrets/db_password.txt`

### Regular user access

A second user is also created automatically:
- **Username**: the value of `WP_USER`
- **Password**: the content of `secrets/db_password.txt`

## Locating and managing credentials

All credentials are stored in two places:

```
secrets/
├── db_password.txt       ← password for WordPress database user and WordPress users
└── db_root_password.txt  ← password for MariaDB root user

srcs/.env                 ← usernames, emails, domain name, database name
```

These files are never committed to Git. To change a password, edit the relevant file and run `make re` to rebuild everything.

## Checking that services are running correctly

```bash
# See all running containers
docker ps

# Expected output:
# nginx      Up X minutes   0.0.0.0:443->443/tcp
# wordpress  Up X minutes
# mariadb    Up X minutes

# Check container logs
docker logs nginx
docker logs wordpress
docker logs mariadb

# Check volumes
docker volume ls
docker volume inspect srcs_wordpress
docker volume inspect srcs_mariadb

# Check the network
docker network ls
docker network inspect srcs_inception
```

If a container is not running, check its logs for errors:

```bash
docker logs <container_name>
```
