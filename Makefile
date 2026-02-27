NAME	= inception

DATA_PATH	= /home/caide-so/data
MARIADB_PATH	= ${DATA_PATH}/mariadb
WORDPRESS_PATH	= ${DATA_PATH}/wordpress

all: up

up:
	mkdir -p ${MARIADB_PATH}
	mkdir -p ${WORDPRESS_PATH}
	docker compose up --build -d

down:
	docker compose down

clean:
	docker compose down -v

fclean: clean
	sudo rm -rf ${DATA_PATH}

re: fclean up

.PHONY: all up down clean fclean re
