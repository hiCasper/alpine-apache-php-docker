FROM alpine:3.15

ADD docker-entrypoint.sh /

RUN apk add --no-cache \
  curl php7-apache2 php7-bcmath php7-bz2 php7-calendar php7-ctype php7-curl php7-dom php7-exif php7-fileinfo php7-gd php7-intl php7-json php7-mbstring php7-mysqli php7-mysqlnd php7-opcache php7-openssl php7-pdo_mysql php7-pdo_pgsql php7-pdo_sqlite php7-pecl-mcrypt php7-pecl-redis php7-pecl-uuid  php7-pgsql php7-phar php7-session php7-sockets php7-sodium php7-sqlite3 php7-xml php7-xmlrpc php7-zip \
  && mkdir /www \
  && chmod +x /docker-entrypoint.sh

EXPOSE 80 443

#HEALTHCHECK --start-period=30s \
#  CMD wget -q --no-cache --spider localhost

ENTRYPOINT ["/docker-entrypoint.sh"]