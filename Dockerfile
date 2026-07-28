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
    && rm -rf /var/lib/apt/lists/*

# Install ttyd (not available from Debian apt)
RUN wget -O /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 \
    && chmod +x /usr/local/bin/ttyd

EXPOSE 8080

CMD ["ttyd", "-p", "8080", "-W", "bash", "-l"]
