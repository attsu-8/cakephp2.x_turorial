FROM php:5.6-apache

# 古い Debian リポジトリを archive.debian.org に変更しつつ、stretch-updates を削除
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# タイムゾーン環境変数（これはPHPには直接効かないけどログなどに有用）
ENV TZ=Asia/Tokyo

# Apacheのドキュメントルート（CakePHPのwebroot）
ENV APACHE_DOCUMENT_ROOT /var/www/html/app/webroot

# ドキュメントルートを反映
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# PHP拡張のインストール
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring gd \
    && a2enmod rewrite

# ⚠️ PHP のタイムゾーン設定を php.ini に追加（PHP5.6向けのDebianパス）
RUN echo "date.timezone = Asia/Tokyo" >> /usr/local/etc/php/php.ini || \
    echo "date.timezone = Asia/Tokyo" >> /etc/php5/apache2/php.ini

# 作業ディレクトリを指定
WORKDIR /var/www/html
