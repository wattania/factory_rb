#DB_HOST=192.168.137.162
DB_HOST=192.168.21.4
DB_USER=factory_rb

HOST_PROJ=$(pwd)
HOST___RAILS_ROOT=$HOST_PROJ/rails_app
DOCKER_RAILS_ROOT=/opt/rails_app

docker run --rm -it \
-h "factory_rb-dev-linux" \
-e "DB_HOST=$DB_HOST" \
-e "DB_USER=$DB_USER" \
-p 3000:3000 \
-v $HOST___RAILS_ROOT:$DOCKER_RAILS_ROOT \
docker.io/wattania/factory_rb:latest \
/bin/bash