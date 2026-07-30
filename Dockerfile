FROM debian:bookworm

# 1. Non-interactive mode prevents apt from hanging on prompts
ENV DEBIAN_FRONTEND=noninteractive

# 2. Combine update, upgrade, package install, and apt cleanup in one layer
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
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

# 3. Download ttyd static binary
RUN wget -O /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 \
    && chmod +x /usr/local/bin/ttyd

# 4. Copy configuration scripts and set execution permissions in a single layer
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
COPY git-sync.sh /git-sync.sh

RUN chmod +x /entrypoint.sh /git-sync.sh

EXPOSE 8080

# 5. Clean entrypoint execution
CMD ["/entrypoint.sh"]
