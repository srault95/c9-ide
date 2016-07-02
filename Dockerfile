FROM srault95/baseimage-docker:xenial

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

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    bzip2 \
    sudo \
    build-essential \
    language-pack-en \
    language-pack-fr \    
    git ca-certificates curl wget \
    python3-dev python3-setuptools \
    supervisor \
    nginx \
	redis-server \
    phantomjs \
    g++ curl libssl-dev apache2-utils git libxml2-dev sshfs
#	nodejs npm \

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
	&& apt-get install -y nodejs

#g++ apache2-utils sshfs libxml2-dev chrpath libfreetype6 libfreetype6-dev fontconfig libssl-dev libfontconfig1 imagemagick \
#    tcl \
#    tmux \
    
#RUN apt-get install libpam-cracklib -y
#RUN ln -s /lib/x86_64-linux-gnu/security/pam_cracklib.so /lib/security    

# node.js 0.12
#RUN curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash - && \
#    apt-get install -y --no-install-recommends nodejs && \
#   npm set strict-ssl false && \
#    npm install -g npm && \
#    npm cache clear

# node.js 0.12 - binary
#RUN curl -SLO http://nodejs.org/dist/latest/node-v$NODE_VERSION-linux-x64.tar.gz && \
#    tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 && \
#    rm "node-v$NODE_VERSION-linux-x64.tar.gz" && \
#    npm install -g npm@"$NPM_VERSION" && \
#    npm cache clear

ENV LANG en_US.UTF-8

RUN locale-gen en_US && \
  locale-gen en_US.UTF-8 && \
  locale-gen fr_FR && \
  locale-gen fr_FR.UTF-8 && \
  dpkg-reconfigure locales
  
RUN curl -k https://bootstrap.pypa.io/get-pip.py | python3 -

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

#ADD gen-ssl.sh /usr/local/bin/
#RUN chmod +x /usr/local/bin/gen-ssl.sh
#ADD start.sh /usr/local/bin/
#RUN chmod +x /usr/local/bin/start.sh

VOLUME /etc/nginx/virtual
VOLUME /workspace

WORKDIR /workspace

EXPOSE 443

RUN apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/cache /var/lib/log \
    && rm -rf /usr/share/doc /usr/share/doc-base /usr/share/man /usr/share/locale /usr/share/zoneinfo \
    && npm cache clear

CMD ["/scripts/start.sh"]

