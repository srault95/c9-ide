
FROM ubuntu:trusty

ADD sources.list /etc/apt/sources.list

#TODO: /etc/cron.d/mongodb-backup
#@daily root mkdir -p /var/backups/mongodb; mongodump --db todos --out /var/backups/mongodb/$(date +'\%Y-\%m-\%d')

ENV DEBIAN_FRONTEND noninteractive

ENV SSL_COMMON_NAME localhost
ENV SSL_RSA_BIT 4096
ENV SSL_DAYS 365

ENV LOGIN_USER admin
ENV LOGIN_PASSWORD admin

ENV BIND_IP 127.0.0.1
ENV PORT 8080

# this allows Meteor to figure out correct IP address of visitors
END HTTP_FORWARDED_COUNT 1
#END MAIL_URL smtp://localhost

ENV NODE_VERSION 0.12.4
ENV NPM_VERSION 2.11.0

RUN \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
  echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' > /etc/apt/sources.list.d/mongodb.list && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C && \
  echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" > /etc/apt/sources.list.d/nginx-stable-trusty.list && \
  apt-get update && \
  apt-get dist-upgrade -y --no-install-recommends

RUN apt-get install -y --no-install-recommends \
    bzip2 \
    sudo \
    build-essential \
    language-pack-en \
    language-pack-fr \    
    rsyslog \
    openssh-server \
    supervisor \
    git \
    ca-certificates \
    curl \
    wget \
    python-dev \
    python \
    fabric \
    g++ apache2-utils sshfs libxml2-dev chrpath libfreetype6 libfreetype6-dev fontconfig libssl-dev libfontconfig1 imagemagick \
    nginx \
    mongodb-org \
    tcl \
    tmux
    
#RUN apt-get install libpam-cracklib -y
#RUN ln -s /lib/x86_64-linux-gnu/security/pam_cracklib.so /lib/security    
    
RUN curl -SLO http://nodejs.org/dist/latest/node-v$NODE_VERSION-linux-x64.tar.gz && \
    tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 && \
    rm "node-v$NODE_VERSION-linux-x64.tar.gz" && \
    npm install -g npm@"$NPM_VERSION" && \
    npm cache clear

ENV PATH /usr/local/bin:${PATH}
ENV LANG en_US.UTF-8

RUN locale-gen en_US && \
  locale-gen en_US.UTF-8 && \
  locale-gen fr_FR && \
  locale-gen fr_FR.UTF-8 && \
  dpkg-reconfigure locales
  
#TODO: ansible
#TODO: conf nginx
#TODO: ssl  

RUN curl -k -O https://bootstrap.pypa.io/ez_setup.py && python ez_setup.py --insecure && rm -f ez_setup.py setuptools*zip

RUN curl -k -O https://bootstrap.pypa.io/get-pip.py && python get-pip.py && rm -f get-pip.py

RUN curl -L http://download.redis.io/releases/redis-3.0.2.tar.gz > redis.tar.gz && \
    mkdir /redis && tar -zxf redis.tar.gz -C /redis --strip 1 && rm redis.tar.gz && \
    cd /redis && make && make test && make install && ln -s /usr/local/bin/redis-server /usr/bin/redis-server

RUN npm install -g \
    forever \
    phantomjs \
    fibers \
    bower \
    grunt-cli \
    gulp \
    node-gyp \
    yo \
    iron-meteor \
    demeteorizer

RUN echo "PS1='(container)\u@\h:\w\$ '" >> /root/.bashrc

RUN mkdir -p /workspace /data /root/.ssh /var/run/sshd /var/log/supervisor /var/log/nginx /data/db && \
    chmod 700 /root/.ssh && \
    rm -f /etc/nginx/sites-enabled/* /etc/nginx/sites-available/* && \
    chown www-data /var/log/nginx && \
    echo "alias ctl='supervisorctl -c /etc/supervisor/supervisord.conf'" >> /root/.bashrc
    
ADD nginx.conf /etc/nginx/
ADD supervisord.conf /etc/supervisor/

RUN sed -i 's/PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
#sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config

RUN git clone https://github.com/c9/core.git /cloud9 && \
    cd /cloud9 && \
    ./scripts/install-sdk.sh && \
    sed -i -e 's_127.0.0.1_0.0.0.0_g' /cloud9/configs/standalone.js 

RUN curl https://install.meteor.com/ |sh

ADD gen-ssl.sh /usr/local/bin/

ADD start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

VOLUME /home/persist/git/repos

VOLUME /workspace

WORKDIR /workspace

EXPOSE 443

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/usr/local/bin/start.sh"]

