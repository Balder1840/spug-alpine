FROM --platform=$TARGETPLATFORM python:3.11.3-alpine3.18

WORKDIR /app
COPY ./spug /app

# 之前出现PyNaCl编译过慢问题
# https://pypi.org/project/PyNaCl/
# ENV LIBSODIUM_MAKE_ARGS=-j4
# ENV SODIUM_INSTALL=system

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
    apk add --no-cache --no-progress --virtual .build-deps \
    build-base \
    python3-dev \
    openldap-dev \
    libffi-dev \
    musl-dev \
    libsodium-dev \
    openssl-dev \
    cargo \
    pkgconfig \
    gcc


COPY <<EOF  /root/.cargo/config
    [source.crates-io]
    registry = "https://github.com/rust-lang/crates.io-index"
    replace-with = "ustc"
    [source.ustc]
    registry = "https://mirrors.ustc.edu.cn/crates.io-index"
EOF


RUN cd spug_api && \
    pip3 install --no-cache-dir -U pip -i https://pypi.tuna.tsinghua.edu.cn/simple/ && \
    export SODIUM_INSTALL=system && pip3 install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple/ && \
    pip3 install --no-cache-dir gunicorn -i https://pypi.tuna.tsinghua.edu.cn/simple/ && \
    apk del .build-deps

# 之前出现bcrypt，cryptography编译不过情况
# https://cryptography.io/en/latest/installation/#alpine
# musl-dev openssl-dev cargo pkgconfig


COPY docker/init_spug /usr/bin/
COPY docker/nginx.conf /etc/nginx/
COPY docker/ssh_config /etc/ssh/
COPY docker/spug.ini /etc/supervisor.d/
COPY docker/redis.conf /etc/
COPY docker/entrypoint.sh /

RUN chmod +x /enterpoint.sh && chmod +x /usr/bin/init_spug && chmod +x /app/spug_api/tools/*.sh


RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
    apk --no-cache --no-progress add \
    supervisor \
    redis \
    nginx \
    sqlite \
    tzdata \
    bash \
    curl \
    git \
    libldap \
    rsync \
    openssh-client


#RUN localedef -c -i en_US -f UTF-8 en_US.UTF-8

ENV TZ=Asia/Shanghai
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8


RUN mkdir -p /app/logs/nginx && mkdir -p /app/logs/redis && mkdir -p /app/logs/spug
VOLUME ["/app/data", "/app/logs"]

EXPOSE 80

CMD ["/entrypoint.sh"]
