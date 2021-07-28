# Base Image
FROM debian:stretch-slim

# Update Image & Install Dependency
RUN apt update \
	&& apt install -y \
		apache2 \
		libapache2-mod-php \
		php7.0 \
		php7.0-pdo \
		php7.0-dev \
		php7.0-curl \
		php7.0-zip \
		unzip \
		vim \
		libaio1 \
	&& apt-get clean \
    && rm -r /var/lib/apt/lists/*

WORKDIR /
ENV LD_LIBRARY_PATH /usr/local/instantclient_18_5/

# Apache Config
# Allow .htaccess with RewriteEngine.
RUN a2enmod rewrite

# Authorise .htaccess files.
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Instant Client Oracle
COPY instantclient-basic-linux.x64-18.5.0.0.0dbru.zip /tmp/
COPY instantclient-sqlplus-linux.x64-18.5.0.0.0dbru.zip /tmp/
COPY instantclient-tools-linux.x64-18.5.0.0.0dbru.zip /tmp/
COPY instantclient-sdk-linux.x64-18.5.0.0.0dbru.zip /tmp/

RUN unzip /tmp/instantclient-basic-linux.x64-18.5.0.0.0dbru.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-18.5.0.0.0dbru.zip -d /usr/local/
RUN unzip /tmp/instantclient-tools-linux.x64-18.5.0.0.0dbru.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-18.5.0.0.0dbru.zip -d /usr/local/
RUN ln -s -f /usr/local/instantclient_18_5 /usr/local/instantclient
RUN ln -s -f /usr/local/instantclient/libclntsh.so.18.1 /usr/local/instantclient/libclntsh.so
RUN ln -s -f /usr/local/instantclient/sqlplus /usr/bin/sqlplus

# Remove file installation
RUN rm /tmp/instantclient-basic-linux.x64-18.5.0.0.0dbru.zip
RUN rm /tmp/instantclient-tools-linux.x64-18.5.0.0.0dbru.zip
RUN rm /tmp/instantclient-sqlplus-linux.x64-18.5.0.0.0dbru.zip
RUN rm /tmp/instantclient-sdk-linux.x64-18.5.0.0.0dbru.zip

# Enable Mod OCI 8
RUN echo 'instantclient,/usr/local/instantclient' | pecl install oci8-2.2.0
RUN echo "extension=oci8.so" > /etc/php/7.0/mods-available/oci8.ini
RUN echo /usr/local/instantclient_18_5 > /etc/ld.so.conf.d/oracle-instantclient.conf
RUN ldconfig
RUN phpenmod oci8

# Expose Port 80 and 443
EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D FOREGROUND"]