# ARGS = $(filter-out $@,$(MAKECMDGOALS))
# MAKEFLAGS += --silent

# https://github.com/maxpou/docker-symfony
# https://github.com/schliflo/bedrock-docker

redelivre: start app_lc_migrations app_wp_migrations app_mc_migrations
	make urls

app_lc_build_frontend:
	docker-compose exec app_lc php app/console assets:install
	docker-compose exec app_lc rm -rf app/cache/prod
	docker-compose exec app_lc php app/console assetic:dump -e prod
	docker-compose exec app_lc chmod -R 777 /var/www/html/app/cache/

app_lc_migrations:
  sleep: 5
	docker-compose exec mariadb mysql -uroot -p"11111" -e "create database lc;"
	docker-compose exec app_lc php app/console doctrine:schema:create
	docker-compose exec app_lc php app/console lc:database:populate batch/
	docker-compose exec app_lc php app/console doctrine:schema:update --force

app_mc_migrations:
	docker-compose exec app_mc ./scripts/db-update.sh
	docker-compose exec app_mc ./scripts/mc-db-updates.sh -d mc.redelivre
	docker-compose exec app_mc ./scripts/generate-proxies.sh
	# docker-compose exec postgres psql -d mapas -U mapas -f ../db/schema.sql
	# docker-compose exec postgres psql -d mapas -U mapas -f ../db/initial-data.sql

app_wp_migrations:
	docker-compose exec app_wp wp --allow-root core install  --path=./web/wp --url=https://redelivre --title=teste-redelivre --admin_user=root --admin_password=123 --skip-email --admin_email=teste@teste.com
	docker-compose exec app_wp wp --allow-root plugin activate wpro

start:
	docker-compose up -d app_lc web_lc
	docker-compose up -d app_mc web_mc
	docker-compose up -d app_wp web_wp
	docker-compose up -d traefik

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
	make start

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
	@echo ""
	@echo "-------------------------------------------------"

clean:
	@docker-compose down -v --remove-orphans


status:
	docker-compose ps

logs:
	docker-compose logs -f --tail=50

# check-proxy:
# 	bash ./.utils/check-proxy.sh

#############################
# Argument fix workaround
#############################
%:
	@:
