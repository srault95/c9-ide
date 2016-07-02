FROM srault95/baseimage-docker:xenial

MAINTAINER STEPHANE RAULT <stephane.rault@radicalspam.org>

ENV DISABLE_SSH 1

ENV SSL_COMMON_NAME localhost
ENV SSL_RSA_BIT 4096
ENV SSL_DAYS 365

ENV LOGIN_USER admin
ENV LOGIN_PASSWORD admin

ENV BIND_IP 127.0.0.1
ENV PORT 8080

ENV TERM screen

# this allows Meteor to figure out correct IP address of visitors
ENV HTTP_FORWARDED_COUNT "1"
#END MAIL_URL smtp://localhost

#ENV NODE_VERSION 0.12.4
#ENV NPM_VERSION 2.11.0
ENV MONGO_VERSION 3.2.7

ENV PATH /root/.c9/bin:/root/.c9/node_modules/.bin:/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN rm -f /etc/cron.daily/logrotate

#MongoDB
RUN curl -O https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-${MONGO_VERSION}.tgz \
    && tar -xzf mongodb-linux-x86_64-${MONGO_VERSION}.tgz \
    && mv mongodb-linux-x86_64-${MONGO_VERSION}/bin/* /usr/local/bin \
    && rm -rf mongodb-linux-x86_64-${MONGO_VERSION}*

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    bzip2 \
    sudo \
    build-essential \
    g++ apache2-utils sshfs libxml2-dev chrpath libfreetype6 libfreetype6-dev fontconfig libssl-dev libfontconfig1 imagemagick \
    language-pack-en \
    language-pack-fr \    
    git ca-certificates curl wget \
    supervisor \
    python3-dev python3-setuptools \
    nginx \
	redis-server \
    phantomjs \
    net-tools

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
	&& apt-get install -y nodejs

ENV LANG en_US.UTF-8

RUN locale-gen en_US && \
  locale-gen en_US.UTF-8 && \
  locale-gen fr_FR && \
  locale-gen fr_FR.UTF-8 && \
  dpkg-reconfigure locales
  
RUN curl -k https://bootstrap.pypa.io/get-pip.py | python3 - \
	&& curl -k https://bootstrap.pypa.io/get-pip.py | python2 -

RUN echo "PS1='(docker)\u@\h:\w\$ '" >> /root/.bashrc

RUN mkdir -p /workspace /data /var/log/supervisor /var/log/nginx /data/db \
	&& rm -f /etc/nginx/sites-enabled/* /etc/nginx/sites-available/* \
    && chown www-data /var/log/nginx
    
ADD nginx.conf /etc/nginx/
ADD supervisor /etc/supervisor/
ADD scripts /scripts/

RUN echo "alias ctl='supervisorctl -c /etc/supervisor/supervisord.conf'" >> /root/.bashrc \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /etc/service/supervisor \
    && chmod +x /scripts/* \
    && ln -sf /scripts/supervisor.sh /etc/service/supervisor/run

RUN git clone https://github.com/c9/core.git /c9
WORKDIR /c9
RUN scripts/install-sdk.sh \
	&& sed -i -e 's_127.0.0.1_0.0.0.0_g' /c9/configs/standalone.js

RUN curl https://install.meteor.com/ | sh

VOLUME /etc/nginx/virtual
VOLUME /workspace

WORKDIR /workspace

#cloud9 via nginx proxy (ssl)
EXPOSE 443
#meteor app via nginx proxy (ssl)
EXPOSE 8080

#cloud9 direct
EXPOSE 8081
#meteor app direct
EXPOSE 3000

RUN apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/cache /var/lib/log \
    && rm -rf /usr/share/doc /usr/share/doc-base /usr/share/man /usr/share/locale /usr/share/zoneinfo \
    && npm cache clear

CMD ["/scripts/start.sh"]

