ARG VERSION=alpine
FROM nginx:${VERSION} as builder

ENV NCHAN_VERSION 1.1.15
ENV MORE_HEADERS_VERSION=0.33
ENV MORE_HEADERS_GITREPO=openresty/headers-more-nginx-module

# Download sources
RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
    wget "https://github.com/${MORE_HEADERS_GITREPO}/archive/v${MORE_HEADERS_VERSION}.tar.gz" -O extra_module.tar.gz

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN  apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    perl-dev \
    libedit-dev \
    mercurial \
    bash \
    alpine-sdk \
    findutils

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN rm -rf /usr/src/nginx /usr/src/extra_module && mkdir -p /usr/src/nginx /usr/src/extra_module && \
    tar -zxC /usr/src/nginx -f nginx.tar.gz && \
    tar -xzC /usr/src/extra_module -f extra_module.tar.gz

WORKDIR /usr/src/nginx/nginx-${NGINX_VERSION}

# Reuse same cli arguments as the nginx:alpine image used to build
RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
    CONFARGS=${CONFARGS/-Os -fomit-frame-pointer -g/-Os} && \
    sh -c "./configure --with-compat $CONFARGS --add-dynamic-module=/usr/src/extra_module/*" && make modules

# Production container starts here
FROM nginx:${VERSION}

COPY --from=builder /usr/src/nginx/nginx-${NGINX_VERSION}/objs/*_module.so /etc/nginx/modules/

# Copy updated server conf files
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf 
COPY ./nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
RUN ls -al

# Install Node.JS and NPM
RUN apk add --update nodejs npm

# copy package API app and cache API app dependencies
WORKDIR /
COPY ./package*.json ./
RUN npm install && mkdir /api && mv ./node_modules /api

# Set working directory
WORKDIR /api
COPY ./src ./src
# COPY ./apidoc.yaml .

# WORKDIR /api
# COPY package*.json ./
# RUN npm install
# COPY ./src ./src

RUN apk --no-cache add curl

RUN apk update && apk add --no-cache supervisor
COPY supervisord.conf /etc/supervisord.conf

# Our app is running on port 3000 within the container, so need to expose it
EXPOSE 3000
EXPOSE 80

# The command that starts our app
CMD ["supervisord", "-c", "/etc/supervisord.conf"]

