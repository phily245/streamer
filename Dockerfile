FROM debian:buster-slim

ENV NGINX_VERSION=1.18.0
ENV CUSTOM_MODULES "--with-file-aio --with-http_auth_request_module --with-http_ssl_module"

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

RUN addgroup --system --gid 1001 nginx \
    && adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 1001 nginx

WORKDIR /tmp

RUN wget -O http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz

RUN echo $(pwd)

RUN tar -xzvf nginx-$NGINX_VERSION.tar.gz

RUN git clone "https://github.com/sergey-dryabzhinsky/nginx-rtmp-module.git"

RUN ls

RUN pwd

RUN cd nginx-$NGINX_VERSION && ./configure --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --add-module=/tmp/nginx-rtmp-module $CUSTOM_MODULES

RUN cd nginx-$NGINX_VERSION &&  make && make install

RUN nginx -t

CMD ["nginx", "-g", "daemon off;"]