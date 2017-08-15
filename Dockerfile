FROM    alpine:3.3

# Here we use several hacks collected from https://github.com/gliderlabs/docker-alpine/issues/11:
# # 1. install GLibc (which is not the cleanest solution at all) 


# Build variables
ENV     FILEBEAT_VERSION 5.5.1
ENV     FILEBEAT_URL https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz

# Environment variables
ENV     FILEBEAT_HOME /opt/filebeat-${FILEBEAT_VERSION}-linux-x86_64
ENV     PATH $PATH:${FILEBEAT_HOME}
ENV     FILEBEAT_HOST localhost

WORKDIR /opt/

RUN     apk add --update python curl && \
        wget -q -O /etc/apk/keys/sgerrand.rsa.pub "https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub" && \
	wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk" \
             "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-bin-2.25-r0.apk" \
             "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-i18n-2.25-r0.apk" && \
        apk add glibc-2.25-r0.apk glibc-bin-2.25-r0.apk glibc-i18n-2.25-r0.apk && \
	/usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8

RUN     curl -sL ${FILEBEAT_URL} | tar xz -C .
ADD     filebeat.yml ${FILEBEAT_HOME}/
ADD     docker-entrypoint.sh    /entrypoint.sh
RUN     chmod +x /entrypoint.sh

ENTRYPOINT  ["/entrypoint.sh"]
CMD         ["start"]
