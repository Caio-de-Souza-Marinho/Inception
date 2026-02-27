NAME		= inception
DATA_PATH	= ${HOME}/data
MARIADB_PATH	= ${DATA_PATH}/mariadb
WORDPRESS_PATH	= ${DATA_PATH}/wordpress

all: up

up:
	mkdir -p ${MARIADB_PATH}
	mkdir -p ${WORDPRESS_PATH}
	docker compose -f srcs/docker-compose.yml up --build -d

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	sudo rm -rf ${DATA_PATH}

re: fclean up

.PHONY: all up down clean fclean re
