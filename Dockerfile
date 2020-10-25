FROM debian:buster-slim

ENV NGINX_VERSION=1.18.0
ENV CUSTOM_MODULES "--with-file-aio --with-http_auth_request_module --with-http_ssl_module"

WORKDIR /tmp

RUN apt update && \
    apt install -y \
    wget \
    build-essential \
    ffmpeg \
    git \
    libpcre3 \
    libpcre3-dev \
    libssl-dev \
    unzip \
    zlib1g-dev

RUN wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    git clone "https://github.com/sergey-dryabzhinsky/nginx-rtmp-module.git"

RUN addgroup --system --gid 1001 nginx && \
    adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 1001 nginx && \
    mkdir -p /home/videos/vod  && \
    mkdir -p /home/videos/recordings && \
    touch /home/videos/recordings/auth && \
    tar -xzvf nginx-$NGINX_VERSION.tar.gz && \
    cd nginx-$NGINX_VERSION && \
    ./configure --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --add-module=/tmp/nginx-rtmp-module $CUSTOM_MODULES && \
    make && \
    make install && \
    rm -rf nginx*

COPY templates/nginx/nginx.conf /etc/nginx/nginx.conf

ARG RTMP_AUTH_URL=http://localhost/auth
ARG HLS_AUTH_URL=http://localhost/auth

RUN sed -i "s/proxy_pass              http:\/\/localhost\/rtmp-auth;/proxy_pass              $(printf '%s\n' "$RTMP_AUTH_URL" | sed -e 's/[\/&]/\\&/g');/g" /etc/nginx/nginx.conf && \
    sed -i "s/proxy_pass              http:\/\/localhost\/hls-auth;/proxy_pass              $(printf '%s\n' "$HLS_AUTH_URL" | sed -e 's/[\/&]/\\&/g');/g" /etc/nginx/nginx.conf

RUN nginx -t

CMD ["nginx", "-g", "daemon off;"]
