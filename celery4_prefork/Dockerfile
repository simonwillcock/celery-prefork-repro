FROM python:2.7.16-slim-stretch

ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install -y gnupg apt-transport-https

RUN apt update \
    && apt install -y software-properties-common curl \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt install -y \
        pkg-config \
        libmemcached-dev \
        memcached \
        g++ \
        libyajl2 \
        git \
        libpq-dev \
        zlib1g-dev \
        vim \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --uid 1000 --create-home django

RUN mkdir -p /code \
    && pip install "pip==19.0.3"

WORKDIR /code

COPY requirements.txt /code/
RUN pip install -r requirements.txt

USER django
WORKDIR /code

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "dev" ]
