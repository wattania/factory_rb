DB_HOST=127.0.0.1
DB_USER=factory_rb

HOST_PROJ=$(pwd)
HOST___RAILS_ROOT=$HOST_PROJ/rails_app
DOCKER_RAILS_ROOT=/opt/rails_app

docker run --rm -it \
 -h "factory_rb-dev-DO" \
 --volumes-from factory_rb_data \
 -e "DB_HOST=$DB_HOST" \
 -e "DB_USER=$DB_USER" \
 -p 3000:3000 \
 -p 2812:2812 \
 -p 88:80 \
 -p 5432:5432 \
 -v /etc/localtime:/etc/localtime:ro \
 -v $HOST___RAILS_ROOT:$DOCKER_RAILS_ROOT \
 docker.io/wattania/factory_rb:latest \
 /bin/bash
