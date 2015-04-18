FROM wattania/factory_rb:base
MAINTAINER Wattana Inthaphong <wattaint@gmail.com>

## REDIS ######
COPY config/redis/redis.conf /etc/redis.conf
COPY config/redis/initd/redis /etc/init.d/redis
RUN chmod 755 /etc/init.d/redis
COPY config/monit/redis.conf /etc/monit.d/redis.conf

### POSTGRESQL
COPY config/postgresql/postgresql-9.4 /etc/init.d/postgresql-9.4
COPY config/monit/postgresql.conf /etc/monit.d/postgresql.conf

## NGINX 
COPY config/nginx/nginx.conf /opt/nginx/conf/nginx.conf
COPY config/nginx/initd/nginx /etc/init.d/nginx
RUN chmod 755 /etc/init.d/nginx
COPY config/monit/nginx.conf /etc/monit.d/nginx.conf

COPY config/monit/monit.conf /etc/monit.conf
RUN chmod 700 /etc/monit.conf

WORKDIR /tmp
ADD rails_app/Gemfile /tmp/Gemfile
ADD rails_app/Gemfile.lock /tmp/Gemfile.lock
RUN bundle install

WORKDIR /