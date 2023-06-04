# spug 的版本号
export SPUG_DOCKER_VERSION="v3.2.7"
echo "spug版本 ${SPUG_DOCKER_VERSION}"

# 设置镜像名
export IMG_NAME="balder1840/spug-alpine:v3.2.7"
echo "镜像名:${IMG_NAME}"

# 下载必要的文件
if [ ! -d "./spug" ]; then
    # 创建目录
    mkdir -p spug/spug_web

    webFile="web_${SPUG_DOCKER_VERSION}.tar.gz"
    echo "下载 ${webFile}"
    curl -L -o web.tar.gz https://gitee.com/openspug/spug/releases/download/${SPUG_DOCKER_VERSION}/${webFile}
    tar xf web.tar.gz -C ./spug/spug_web/
    rm -rf *.tar.gz

    echo "克隆 版本 ${SPUG_DOCKER_VERSION} 的源码"
    git clone -b $SPUG_DOCKER_VERSION https://gitee.com/openspug/spug.git src
    mv src/spug_api spug/
    rm -rf src
fi

# 替换python-ldap版本, 之前编译是出现编译不过情况
# sed -i 's/python-ldap==3.4.0/python-ldap==3.4.3/g' spug/spug_api/requirements.txt

# 构建镜像
# --provenance false
# docker build -t ${IMG_NAME} .
# docker buildx build --platform=linux/amd64,linux/arm64,linux/arm/v7 --output=type=image -t ${IMG_NAME} .
# docker buildx build --platform=linux/arm/v7 --load -t ${IMG_NAME} .
 docker buildx build --platform=linux/amd64,linux/arm64,linux/arm/v7 --output=type=image -t ${IMG_NAME} .
