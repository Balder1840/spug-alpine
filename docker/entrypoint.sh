#!/bin/bash
#
set -e

if [ -e /root/.bashrc ]; then
    source /root/.bashrc
fi

if [ ! -e /app/spug_api/spug/overrides.py ]; then
    if [ -z "${SECRET_KEY}" ]; then
        SECRET_KEY=$(< /dev/urandom tr -dc '!@#%^.a-zA-Z0-9' | head -c50)
    fi
    cat > /app/spug_api/spug/overrides.py << EOF
import os
from django.conf import settings

DEBUG = False
ALLOWED_HOSTS = ['127.0.0.1']
SECRET_KEY = '${SECRET_KEY}'

# /app/data/repos
REPOS_DIR = os.path.join(os.path.dirname(settings.BASE_DIR), 'data', 'repos')
# /app/storage/transfer
TRANSFER_DIR = os.path.join(os.path.dirname(settings.BASE_DIR), 'data', 'storage', 'transfer')

DATABASES = {
    'default': {
        'ATOMIC_REQUESTS': True,
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(os.path.dirname(settings.BASE_DIR), 'data', 'db', 'db.sqlite3'),
    }
}
EOF
fi

if [ ! -d /app/logs/redis ]; then
  mkdir -p /app/logs/redis
fi

if [ ! -d /app/logs/nginx ]; then
  mkdir -p /app/logs/nginx
fi

if [ ! -d /app/logs/spug ]; then
  mkdir -p /app/logs/spug
fi

if [ ! -d /app/data/db ]; then
  mkdir -p /app/data/db
fi

if [ ! -e /app/data/db/db.sqlite3 ]; then
  python /app/spug_api/manage.py updatedb
  python /app/spug_api/manage.py user add -u admin -p admin -s -n 管理员
fi

exec supervisord -c /etc/supervisord.conf
