# ARGS = $(filter-out $@,$(MAKECMDGOALS))
# MAKEFLAGS += --silent

# https://github.com/maxpou/docker-symfony
# https://github.com/schliflo/bedrock-docker

redelivre: up app_lc_migrations app_mc_migrations app_wp_migrations
	make urls

app_lc_migrations:
	# docker-compose exec app_lc php app/console doctrine:database:create -q
	docker-compose exec app_lc php app/console doctrine:schema:create
	docker-compose exec app_lc php app/console lc:database:populate batch/
	docker-compose exec app_lc php /app/console doctrine:schema:update --force
	docker-compose exec app_lc php /app/console lc:database:populate batch/
	docker-compose exec app_lc php /app/console assets:install
	docker-compose exec app_lc php rm -rf app/cache/prod
	docker-compose exec app_lc php /app/console assetic:dump -e prod

app_mc_migrations:
	# install.sh
	docker-compose exec postgres dropdb -Upostgres --if-exists mapas
	docker-compose exec postgres dropuser -Upostgres --if-exists mapas
	docker-compose exec postgres psql -Upostgres -d postgres -c "CREATE USER mapas WITH PASSWORD 'mapas';"
	docker-compose exec postgres createdb -Upostgres --owner mapas mapas
	docker-compose exec postgres psql -Upostgres -d mapas -c 'CREATE EXTENSION postgis;'
	docker-compose exec postgres psql -Upostgres -d mapas -c 'CREATE EXTENSION unaccent;'

	# docker-compose exec postgres psql -d mapas -U mapas -f ../db/schema.sql
	# docker-compose exec postgres psql -d mapas -U mapas -f ../db/initial-data.sql
	docker-compose exec app_mc php src/protected/apply-updates.php
	docker-compose exec app_mc php src/protected/tools/doctrine.php orm:generate-proxies
	docker-compose exec app_mc php src/protected/mc-updates.php

	# docker-compose exec app_mc bash scripts/db-update.sh
	docker-compose exec app_mc ./scripts/compile-sass.sh mc.redelivre

app_wp_migrations:
	docker-compose exec mariadb mysql -uroot -p"11111" -e "create database wp;"
	docker-compose exec app_wp wp --allow-root core install  --path=./web/wp --url=https://redelivre --title=teste-redelivre --admin_user=root --admin_password=123 --skip-email --admin_email=teste@teste.com
	docker-compose exec app_wp wp --allow-root plugin activate wpro
up:
	docker-compose up -d

stop:
	@echo "Stopping your project..."
	docker-compose stop

destroy: stop
	@echo "Deleting all containers..."
	docker-compose down --rmi all --remove-orphans

upgrade:
	@echo "Upgrading your project..."
	docker-compose pull
	docker-compose build --pull
	# make composer update
	make up

restart: stop up

rebuild: destroy upgrade


#############################
# UTILS
#############################

# mysql-backup:
# 	bash ./.utils/mysql-backup.sh

# mysql-restore:
# 	bash ./.utils/mysql-restore.sh

ci-test:
	bash ./.utils/ci/test.sh


#############################
# CONTAINER ACCESS
#############################

ssh:
	docker exec -it $$(docker-compose ps -q $(ARGS)) sh


#############################
# INFORMATION
#############################

urls:
	@echo "Urls disponíveis"
	@echo "-------------------------------------------------"
	@echo ""
	@echo "Wordpress Admin:    http://redelivre/wp/wp-admin/"
	@echo "Wordpress:          http://redelivre/"
	@echo "Login Cidadão:      http://lc.redelivre/"
	@echo "Mapas Culturais:    http://mc.redelivre/"
	@echo "Servidor de E-mail: http://smtp.redelivre/"
	@echo "Servidor S3:        http://s3.redelivre/"
	@echo "PHPMyAdmin:         http://phpmyadmin.redelivre/"
	@echo "Adminer:            http://adminer.redelivre/"
	echo ""
	@echo "-------------------------------------------------"


state:
	docker-compose ps

logs:
	docker-compose logs -f --tail=50 $(ARGS)

# check-proxy:
# 	bash ./.utils/check-proxy.sh

#############################
# Argument fix workaround
#############################
%:
	@:
