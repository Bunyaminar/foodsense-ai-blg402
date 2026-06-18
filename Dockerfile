FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY foodsense_ai/ .

EXPOSE 5000

CMD ["echo", "Flutter web build required"]
