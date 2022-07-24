#!/bin/sh

# Exit on non defined variables and on non zero exit codes
set -eu

SERVER_ADMIN="${SERVER_ADMIN:-admin@server}"
HTTP_SERVER_NAME="${HTTP_SERVER_NAME:-server}"
HTTPS_SERVER_NAME="${HTTPS_SERVER_NAME:-server}"
HTTP_PORT="${HTTP_PORT:-80}"
HTTPS_PORT="${HTTPS_PORT:-443}"
LOG_LEVEL="${LOG_LEVEL:-warn}"
TZ="${TZ:-Asia/Shanghai}"
PHP_MEMORY_LIMIT="${PHP_MEMORY_LIMIT:-128M}"
PHP_MAX_EXEC_TIME="${PHP_MAX_EXEC_TIME:-60}"

echo 'Updating configurations...'

# Change Server Admin, Name, Document Root
sed -i "s/ServerAdmin\ you@example.com/ServerAdmin\ ${SERVER_ADMIN}/" /etc/apache2/httpd.conf
sed -i "s/#ServerName\ www.example.com:80/ServerName\ ${HTTP_SERVER_NAME}:${HTTP_PORT}/" /etc/apache2/httpd.conf
sed -i 's#^DocumentRoot ".*#DocumentRoot "/www"#g' /etc/apache2/httpd.conf
sed -i 's#^Listen ".*#Listen ${HTTP_PORT}#g' /etc/apache2/httpd.conf
sed -i 's#Directory "/var/www/localhost/htdocs"#Directory "/www"#g' /etc/apache2/httpd.conf
sed -i 's#AllowOverride None#AllowOverride All#' /etc/apache2/httpd.conf
sed -i 's#ServerSignature On#ServerSignature Off#' /etc/apache2/httpd.conf
sed -i 's#ServerTokens OS#ServerTokens Prod#' /etc/apache2/httpd.conf

# Change TransferLog after ErrorLog
sed -i 's#^ErrorLog .*#ErrorLog "/dev/stderr"\nTransferLog "/dev/stdout"#g' /etc/apache2/httpd.conf
sed -i 's#CustomLog .* combined#CustomLog "/dev/stdout" combined#g' /etc/apache2/httpd.conf

# SSL DocumentRoot and Log locations
# sed -i 's#^ErrorLog .*#ErrorLog "/dev/stderr"#g' /etc/apache2/conf.d/ssl.conf
# sed -i 's#^TransferLog .*#TransferLog "/dev/stdout"#g' /etc/apache2/conf.d/ssl.conf
# sed -i 's#^DocumentRoot ".*#DocumentRoot "/www"#g' /etc/apache2/conf.d/ssl.conf
# sed -i "s/ServerAdmin\ you@example.com/ServerAdmin\ ${SERVER_ADMIN}/" /etc/apache2/conf.d/ssl.conf
# sed -i "s/ServerName\ www.example.com:443/ServerName\ ${HTTPS_SERVER_NAME}:${HTTPS_PORT}/" /etc/apache2/conf.d/ssl.conf

# Re-define LogLevel
sed -i "s#^LogLevel .*#LogLevel ${LOG_LEVEL}#g" /etc/apache2/httpd.conf

# Enable commonly used apache modules
sed -i 's/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/' /etc/apache2/httpd.conf
sed -i 's/#LoadModule\ deflate_module/LoadModule\ deflate_module/' /etc/apache2/httpd.conf
sed -i 's/#LoadModule\ expires_module/LoadModule\ expires_module/' /etc/apache2/httpd.conf

# Modify php config
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 8M/" /etc/php7/php.ini
sed -i "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" /etc/php7/php.ini
sed -i "s/max_execution_time = .*/max_execution_time = ${PHP_MAX_EXEC_TIME}/" /etc/php7/php.ini
sed -i "s#^;date.timezone =\$#date.timezone = \"${TZ}\"#" /etc/php7/php.ini

echo 'Starting Apache...'
rm -f /run/apache2/apache2.pid
rm -f /run/apache2/httpd.pid
httpd -D FOREGROUND