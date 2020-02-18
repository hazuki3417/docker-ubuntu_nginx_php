# Please execute the following command to build
# docker build -t nginx_v1.16.0_php7.2 this_file_path
# docker-compose build

# Please execute the following command to start it
# docker run -itd --name nginx_v1.16.0_php7.2 -p 80:80 nginx_v1.16.0_php7.2
# docker-compose up -d

# Please execute the following command to attach
# docker exec -it nginx_v1.16.0_php7.2 /bin/bash

# ベースイメージを指定
FROM hazuki3417/nginx:latest
# 制作者情報を指定
LABEL maintainer="hazuki3417 <hazuki3417@gmail.com>"

# メイン処理
# RUN : "必要なコマンド類をインストール" && \
# 	echo "complate!"

ARG php_version=7.2
ARG php_install_path=/etc/php/${php_version}/fpm
ARG php_pid_file_path=/var/run/php
ARG document_root=/var/www
# 必要なものだけインストールする
RUN : "phpをインストール" & \
	apt-get install -y \
	php7.2 \
	php7.2-bcmath \
	php7.2-bz2 \
	php7.2-cgi \
	php7.2-cli \
	php7.2-common \
	php7.2-curl \
	php7.2-dba \
	php7.2-dev \
	php7.2-enchant \
	php7.2-fpm \
	php7.2-gd \
	php7.2-gmp \
	php7.2-imap \
	php7.2-interbase \
	php7.2-intl \
	php7.2-json \
	php7.2-ldap \
	php7.2-mbstring \
	php7.2-mysql \
	php7.2-odbc \
	php7.2-opcache \
	php7.2-pgsql \
	php7.2-phpdbg \
	php7.2-pspell \
	php7.2-readline \
	php7.2-recode \
	php7.2-snmp \
	php7.2-soap \
	php7.2-sqlite3 \
	php7.2-sybase \
	php7.2-tidy \
	php7.2-xml \
	php7.2-xmlrpc \
	php7.2-xsl \
	php7.2-mongodb \
	php7.2-zip

RUN : "xdebugをインストール" & \
	apt-get install -y \
	php-xdebug

RUN : "phpの設定" && \
	echo "php setting start..." && \
	mkdir -p ${php_pid_file_path} && \
	mkdir -p ${document_root}

COPY config/php/php${php_version}-fpm.pid ${php_pid_file_path}/
COPY config/php/www.conf ${php_install_path}/pool.d/
COPY config/php/index.php ${document_root}/
COPY config/php/xdebug.conf /etc/php/7.2/fpm/conf.d/20-xdebug.ini

RUN : "Nginxの設定" && \
	echo "nginx setting start..." && \
	mkdir ${nginx_install_path}/modules-available && \
	mkdir ${nginx_install_path}/modules-enabled && \
	mkdir ${nginx_install_path}/sites-available && \
	mkdir ${nginx_install_path}/sites-enabled
COPY config/nginx/nginx.conf /etc/nginx/
COPY config/nginx/sites/default_http.conf /etc/nginx/sites-available/
COPY config/nginx/sites/default_https.conf /etc/nginx/sites-available/
COPY config/nginx/sites/default_virtualhost.conf /etc/nginx/sites-available/

WORKDIR /etc/nginx/sites-enabled
RUN : "サイトの設定ファイルを読み込む" && \
	ln -sf ../sites-available/default_http.conf ./defautl_http.conf


WORKDIR /

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod 744 /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

# 指定したディレクトリをマウント
VOLUME ${document_root}
# 指定したポートを開放
EXPOSE 80
