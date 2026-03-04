SHELL		= /bin/bash
NAME		= inception
DATA_PATH	= ${HOME}/data
MARIADB_PATH	= ${DATA_PATH}/mariadb
WORDPRESS_PATH	= ${DATA_PATH}/wordpress

all: up

secrets/db_password.txt:
	@read -s -p "Enter MariaDB user password: " pass && echo $$pass > secrets/db_password.txt && echo ""

secrets/db_root_password.txt:
	@read -s -p "Enter MariaDB root password: " pass && echo $$pass > secrets/db_root_password.txt && echo ""

up: secrets/db_password.txt secrets/db_root_password.txt
	mkdir -p ${MARIADB_PATH}
	mkdir -p ${WORDPRESS_PATH}
	docker compose -f srcs/docker-compose.yml up --build -d

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	sudo rm -rf ${DATA_PATH}
	rm -f secrets/db_password.txt secrets/db_root_password.txt

re: fclean up

.PHONY: all up down clean fclean re
