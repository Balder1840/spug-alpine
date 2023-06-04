FROM python:3.11.3-alpine3.18

WORKDIR /app
COPY ./spug /app

# https://pypi.org/project/PyNaCl/
ENV LIBSODIUM_MAKE_ARGS=-j4

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
    apk add --no-cache --no-progress --virtual .build-deps \
	build-base \
	python3-dev \
	openldap-dev \
    libffi-dev \
    openssl-dev \
    musl-dev \
    make \
    cargo \
    pkgconfig \
	gcc && \
	cd spug_api \
    pip install -U pip \
	pip3 install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple/ && \
	pip3 install --no-cache-dir gunicorn -i https://pypi.tuna.tsinghua.edu.cn/simple/ && \
    apk del .build-deps

# musl-dev openssl-dev make  bcrypt, cryptography -i https://pypi.tuna.tsinghua.edu.cn/simple/
#https://cryptography.io/en/latest/installation/#alpine
# cargo pkgconfig

#pip3 install --no-cache-dir bcrypt -i https://pypi.tuna.tsinghua.edu.cn/simple/ && \
#    pip3 install --no-cache-dir cryptography -i https://pypi.tuna.tsinghua.edu.cn/simple/ && \

COPY docker/init_spug /usr/bin/
COPY docker/nginx.conf /etc/nginx/
COPY docker/ssh_config /etc/ssh/
COPY docker/spug.ini /etc/supervisor.d/
COPY docker/redis.conf /etc/
COPY docker/entrypoint.sh /

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