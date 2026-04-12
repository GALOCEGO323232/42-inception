#!/bin/bash

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/db_password)
WP_USER_PASSWORD=$(cat /run/secrets/db_password)

until mariadb-check -h "$DB_HOST" -u "$MYSQL_USER" -p"$DB_PASSWORD" --all-databases --silent; do
    echo "Waiting MariaDB..."
    sleep 2
done

if [ ! -f /var/www/wordpress/wp-config-sample.php ]; then
    cp -r /var/www/wordpress_backup/. /var/www/wordpress/
fi

if [ ! -f /var/www/wordpress/wp-config.php ]; then
    wp config create --allow-root \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$DB_PASSWORD \
        --dbhost=$DB_HOST \
        --path=/var/www/wordpress
fi

if ! wp core is-installed --allow-root --path=/var/www/wordpress; then
    echo "Instalando o WordPress..."
    wp core install --allow-root \
        --url=$DOMAIN_NAME \
        --title="Inception" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --path=/var/www/wordpress

    echo "Criando o segundo usuário..."
    wp user create $WP_USER $WP_USER_EMAIL \
        --role=author \
        --user_pass=$WP_USER_PASSWORD \
        --allow-root \
        --path=/var/www/wordpress
fi


chown -R www-data:www-data /var/www/wordpress

exec php-fpm8.2 -F