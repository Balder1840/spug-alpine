FROM --platform=$TARGETPLATFORM python:3.11.3-alpine3.18 AS builder

# arm32下cryptography不提供wheel,需使用rust编译
COPY <<EOF /root/.cargo/config
[source.crates-io]
# To use sparse index, change 'rsproxy' to 'rsproxy-sparse'
replace-with = 'rsproxy'

[source.rsproxy]
registry = "sparse+https://rsproxy.cn/index/"

[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"
EOF

WORKDIR /app

COPY ./spug /app/
COPY ./docker /app/docker

# 替换package版本, 之前出现编译不过情况
# python-ldap，cryptography在arm32需要改源
RUN <<EOF
sed -i 's/python-ldap==3.4.0/python-ldap==3.4.3/g' /app/spug_api/requirements.txt
sed -i 's/paramiko==2.11.0/paramiko==2.12.0/g' /app/spug_api/requirements.txt
sed -i '$a autobahn==23.1.2' /app/spug_api/requirements.txt
sed -i '$a cryptography==40.0.2' /app/spug_api/requirements.txt
EOF

# 之前出现PyNaCl编译过慢问题
# https://pypi.org/project/PyNaCl/
# ENV LIBSODIUM_MAKE_ARGS=-j4
# ENV SODIUM_INSTALL=system

WORKDIR /app/pkg/

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
    gcc && \
    export SODIUM_INSTALL=system && \
    pip3 install --no-cache-dir -U pip -i https://pypi.tuna.tsinghua.edu.cn/simple/ && \
    pip3 wheel -r /app/spug_api/requirements.txt -w /app/pkg -i https://pypi.tuna.tsinghua.edu.cn/simple/ && \
    pip3 wheel gunicorn -w /app/pkg -i https://pypi.tuna.tsinghua.edu.cn/simple/ && \
    apk del .build-deps



FROM --platform=$TARGETPLATFORM python:3.11.3-alpine3.18

WORKDIR /app
COPY --from=builder /app/ /app/

#RUN localedef -c -i en_US -f UTF-8 en_US.UTF-8

ENV TZ=Asia/Shanghai
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN <<EOF
pip3 install --no-cache-dir -U pip -i https://pypi.tuna.tsinghua.edu.cn/simple/
pip3 install -r /app/spug_api/requirements.txt --no-index -f /app/pkg/
pip3 install gunicorn --no-index -f /app/pkg/
EOF

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
    libsodium \
    rsync \
    sshfs \
    sshpass \
    openssh-client

RUN <<EOF
cp /app/docker/init_spug /usr/bin/
cp /app/docker/nginx.conf /etc/nginx/
cp /app/docker/ssh_config /etc/ssh/
mkdir /etc/supervisor.d && cp /app/docker/spug.ini /etc/supervisor.d/
cp /app/docker/redis.conf /etc/
cp /app/docker/entrypoint.sh /

chmod +x /enterpoint.sh
chmod +x /usr/bin/init_spug 
chmod +x /app/spug_api/tools/*.sh

rm -rf /app/docker
rm -rf /app/pkg
EOF

RUN mkdir -p /app/logs/nginx && mkdir -p /app/logs/redis && mkdir -p /app/logs/spug
VOLUME ["/app/data", "/app/logs"]

EXPOSE 80

CMD ["/entrypoint.sh"]
