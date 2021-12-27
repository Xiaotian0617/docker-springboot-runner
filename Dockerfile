FROM alpine:latest
MAINTAINER Lemon

# 设置清华大学数据源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN apk update && apk upgrade && apk add fontconfig ttf-dejavu && apk add curl && apk add vim

RUN apk --no-cache add ca-certificates

# 下载必备运行库
RUN apk --no-cache add libstdc++ ca-certificates bash  wget && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-bin-2.34-r0.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-i18n-2.34-r0.apk && \
    apk add glibc-2.34-r0.apk && apk add glibc-bin-2.34-r0.apk && apk add glibc-i18n-2.34-r0.apk && \
    rm -rfv glibc-2.34-r0.apk glibc-bin-2.34-r0.apk glibc-i18n-2.34-r0.apk

RUN curl -Ls https://archive.archlinux.org/packages/z/zlib/zlib-1%3A1.2.11-3-x86_64.pkg.tar.xz -o libz.tar.xz && mkdir -p libz && tar -xf libz.tar.xz -C libz

RUN mv libz/usr/lib/libz.so* /usr/glibc-compat/lib

RUN rm -rf libz.tar.xz

# 设置系统环境 防止中文乱码
COPY ./locale.md /locale.md
RUN cat locale.md | xargs -i /usr/glibc-compat/bin/localedef -i {} -f UTF-8 {}.UTF-8 && \
    rm -rfv locale.md

WORKDIR /tools

# x86平台 jdk
ADD ./openjdk-17.0.1_linux-x64_bin.tar.gz /tools/
# aarch64平台 jdk
# ADD ./openjdk-17.0.1_linux-aarch64_bin.tar.gz /tools/
# aarch64 macos平台 jdk
# ADD ./openjdk-17.0.1_macos-aarch64_bin.tar.gz /tools/

RUN adduser -S -u 1000 springboot && \
    mkdir -p /app && \
    chown -R springboot /app

ADD entrypoint.sh /usr/local/bin/

USER springboot

ENV LANG C.UTF-8
ENV JAVA_HOME=/tools/jdk-17.0.1
ENV CLASSPATH=$JAVA_HOME/bin
ENV PATH=.:$JAVA_HOME/bin:$PATH

WORKDIR /app

VOLUME /app
EXPOSE 8080

# CMD ["java","-version"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

