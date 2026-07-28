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
    ttyd \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8080

CMD ["ttyd", "-p", "8080", "-W", "bash"]
