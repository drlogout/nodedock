FROM ubuntu:24.04

ARG PHP_VERSION=8.3
ARG NODE_VERSION=22.14
ENV PHP_VERSION=${PHP_VERSION}
ENV NODE_VERSION=${NODE_VERSION}

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Set timezone to UTC
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update --fix-missing && \
    apt install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt install -y \
    git \
    gosu \
    nginx \
    jq \
    sudo \
    rsync \
    unzip \
    vim \
    zip && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

RUN echo www-data ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/www-data \
    && chmod 0440 /etc/sudoers.d/www-data

# Nginx config
RUN rm -f /etc/nginx/sites-enabled/* && rm -f /etc/nginx/sites-available/*
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/sites-available/ /etc/nginx/sites-available/
COPY nginx/mime.types /etc/nginx/mime.types
COPY nginx/conf.d/ /etc/nginx/conf.d/

# Scripts
COPY scripts/deploy.sh /usr/local/bin/deploy

COPY index.html /var/www/html/public/index.html

EXPOSE 80

WORKDIR /var/www/html

RUN chown -R www-data:www-data /var/www

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN echo www-data ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/www-data \
    && chmod 0440 /etc/sudoers.d/www-data

USER www-data

RUN curl https://get.volta.sh | bash && \
    /var/www/.volta/bin/volta install node@$NODE_VERSION

# Switch back to root for entrypoint to handle user/group setup
USER root

ENTRYPOINT [ "/entrypoint.sh" ]
