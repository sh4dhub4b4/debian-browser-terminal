FROM debian:bookworm

RUN apt update && apt install -y \
    bash \
    curl \
    wget \
    python3 \
    python3-pip \
    nano \
    vim \
    htop \
    git \
    ca-certificates \
    nginx \
    apache2-utils \
    supervisor \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*


RUN wget -O /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 \
    && chmod +x /usr/local/bin/ttyd


COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh


RUN chmod +x /entrypoint.sh


EXPOSE 8080
EXPOSE 7681


CMD ["/entrypoint.sh"]
