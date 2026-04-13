NAME = inception

IP = $(shell hostname -I | awk '{print $$1}')

all: create_dirs setup_hosts
	cd srcs && docker compose up --build -d

create_dirs:
	mkdir -p /home/kgagliar/data/wordpress
	mkdir -p /home/kgagliar/data/mariadb

setup_hosts:
	grep -q "kgagliar.42.fr" /etc/hosts || \
	echo "$(IP) kgagliar.42.fr" | sudo tee -a /etc/hosts

down:
	cd srcs && docker compose down

clean:
	cd srcs && docker compose down -v

fclean: clean
	docker rmi -f $(shell docker images -qa)
	sudo rm -rf /home/kgagliar/data

re: fclean all

.PHONY: all create_dirs setup_hosts down clean fclean re
