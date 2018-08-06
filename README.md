# Rede Livre Install

Installe a redelivre en su computador hoje ! we ♥ DX
[![Join the chat at https://telegram.me/IdentidadeDigital](https://patrolavia.github.io/telegram-badge/chat.png)](https://t.me/RedeLivreOrg)

## Infraestrutura da #RedeLivre

Essa etapa tentar garantir aos desenvolvedores instalarem a Rede Livre em seu próprio computador. Para isso, algumas dependências obrigatórias são necessárias: o [Docker](https://rancher.com/docs/rancher/v1.6/en/hosts/#supported-docker-versions), o [Docker Compose](https://github.com/docker/compose/releases/tag/1.22.0) e o Make.

A Rede Livre é, por enquanto, formada por 3 produtos principais: [Login Cidadão](https://github.com/redelivre/login-cidadao), [Mapas Culturais](https://github.com/hacklabr/mapasculturais) e [Wordpress](https://github.com/redelivre/2.0).


Para instalar o docker, experimente executar o seguinte comando:

```bash
curl https://releases.rancher.com/install-docker/18.03.sh | sh
```

Em seguida, adicione ao seu host as seguintes linhas:

```bash
127.0.0.1 mapas.redelivre
127.0.0.1 lc.redelivre
127.0.0.1 redelivre
127.0.0.1 smtp.redelivre s3.redelivre elk.redelivre phpmyadmin.redelivre redelivre lb.redelivre adminer.redelivre
```

E então, execute o comando:

```bash
mkdir redelivre
git clone https://github.com/redelivre/install
cd install
make redelivre
```

Subirão alguns serviços depois de 120 minutos, dependendo da conexão com a internet e do processador do computador. As urls adicionadas ao host estarão funcionando correntamente, se tudo deu certo no build.

Caso ocorra algum problema, execute o comando:

```bash
make status
```

Abaixo um quadro de como devem aparecer os serviços após inicializados:

```bash
$ docker-compose ps
         Name                        Command                  State                                    Ports
------------------------------------------------------------------------------------------------------------------------------------------
rl-install_app_lc_1       docker-php-entrypoint php-fpm    Up             9000/tcp
rl-install_app_mc_1       docker-php-entrypoint php-fpm    Up             9000/tcp
rl-install_app_wp_1       /entrypoint supervisord          Up             9000/tcp
rl-install_elk_1          /usr/bin/supervisord -n -c ...   Up             0.0.0.0:84->80/tcp
rl-install_mariadb_1      docker-entrypoint.sh mysqld      Up             0.0.0.0:3306->3306/tcp
rl-install_memcached_1    docker-entrypoint.sh memcached   Up             0.0.0.0:11211->11211/tcp
rl-install_phpmyadmin_1   /run.sh supervisord -n           Up             80/tcp, 9000/tcp
rl-install_postgres_1     docker-entrypoint.sh postgres    Up             0.0.0.0:5432->5432/tcp
rl-install_redis_1        docker-entrypoint.sh redis ...   Up             0.0.0.0:6379->6379/tcp
rl-install_s3_1           /usr/bin/docker-entrypoint ...   Up (healthy)   0.0.0.0:9000->9000/tcp
rl-install_smtp_1         MailHog                          Up             0.0.0.0:1025->1025/tcp, 0.0.0.0:8025->8025/tcp
rl-install_traefik_1      /traefik                         Up             0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp, 0.0.0.0:8080->8080/tcp
rl-install_web_lc_1       nginx                            Up             0.0.0.0:436->443/tcp, 0.0.0.0:83->80/tcp
rl-install_web_mc_1       nginx                            Up             0.0.0.0:435->443/tcp, 0.0.0.0:82->80/tcp
rl-install_web_wp_1       /bin/sh -c envsubst $VIRT ...    Up             0.0.0.0:434->443/tcp, 0.0.0.0:81->80/tcp
```

Dessa forma vai conseguir visualizar em qual parte do build você teve problemas.

## Novos serviços

Caso queira adicionar um novo serviço na infraestrutura da rede livre, [crie um pull request](https://help.github.com/articles/creating-a-pull-request/).

## Comandos úteis

```bash
# bash commands
$ docker-compose exec app_lc bash

# Composer (e.g. composer update)
$ docker-compose exec app_lc composer update

# SF commands (Tips: there is an alias inside app_lc container)
$ docker-compose exec app_lc php /var/www/html/app/console cache:clear # Symfony2
$ docker-compose exec app_lc php /var/www/html/bin/console cache:clear # Symfony3
# Same command by using alias
$ docker-compose exec app_lc bash
$ sf cache:clear

# Retrieve an IP Address (here for the nginx container)
$ docker inspect --format '{{ .NetworkSettings.Networks.dockersymfony_default.IPAddress }}' $(docker ps -f name=web_lc -q)
$ docker inspect $(docker ps -f name=web_lc -q) | grep IPAddress

# MySQL commands
$ docker-compose exec mariadb mysql -uroot -p

# F***ing cache/logs folder
$ sudo chmod -R 777 app/cache app/logs # Symfony2
$ sudo chmod -R 777 var/cache var/logs var/sessions # Symfony3

# Check CPU consumption
$ docker stats $(docker inspect -f "{{ .Name }}" $(docker ps -q))

# Delete all containers
$ docker rm $(docker ps -aq)

# Delete all images
$ docker rmi $(docker images -q)
```
