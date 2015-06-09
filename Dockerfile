FROM ubuntu:trusty

ADD sources.list /etc/apt/sources.list

ENV DEBIAN_FRONTEND noninteractive

ENV SSL_COMMON_NAME localhost
ENV SSL_RSA_BIT 4096
ENV SSL_DAYS 365

ENV LOGIN_USER admin
ENV LOGIN_PASSWORD admin

ENV BIND_IP 127.0.0.1
ENV PORT 8080

ENV TERM screen

# this allows Meteor to figure out correct IP address of visitors
END HTTP_FORWARDED_COUNT "1"
#END MAIL_URL smtp://localhost

ENV NODE_VERSION 0.12.4
ENV NPM_VERSION 2.11.0

ENV PATH /root/.c9/bin:/root/.c9/node_modules/.bin:/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

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
    tmux \
    phantomjs

#TODO: phantomjs 2.0 a compiler: http://phantomjs.org/build.html
    
#RUN apt-get install libpam-cracklib -y
#RUN ln -s /lib/x86_64-linux-gnu/security/pam_cracklib.so /lib/security    

# node.js 0.12
RUN curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm set strict-ssl false && \
    npm install -g npm && \
    npm cache clear

# io.js 2.x
# RUN curl -sL https://deb.nodesource.com/setup_iojs_2.x | sudo bash - && \
#   apt-get install -y --no-install-recommends iojs && \
#    npm install -g npm@"$NPM_VERSION" && \
#    npm cache clear

# node.js 0.12 - binary
#RUN curl -SLO http://nodejs.org/dist/latest/node-v$NODE_VERSION-linux-x64.tar.gz && \
#    tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 && \
#    rm "node-v$NODE_VERSION-linux-x64.tar.gz" && \
#    npm install -g npm@"$NPM_VERSION" && \
#    npm cache clear

#ENV PATH /usr/local/bin:${PATH}
ENV LANG en_US.UTF-8

RUN locale-gen en_US && \
  locale-gen en_US.UTF-8 && \
  locale-gen fr_FR && \
  locale-gen fr_FR.UTF-8 && \
  dpkg-reconfigure locales
  
RUN curl -k -O https://bootstrap.pypa.io/ez_setup.py && python ez_setup.py --insecure && rm -f ez_setup.py setuptools*zip

RUN curl -k -O https://bootstrap.pypa.io/get-pip.py && python get-pip.py && rm -f get-pip.py

RUN curl -L http://download.redis.io/releases/redis-3.0.2.tar.gz > redis.tar.gz && \
    mkdir /redis && tar -zxf redis.tar.gz -C /redis --strip 1 && rm redis.tar.gz && \
    cd /redis && make && make test && make install && ln -s /usr/local/bin/redis-server /usr/bin/redis-server

RUN echo "PS1='(docker)\u@\h:\w\$ '" >> /root/.bashrc

RUN mkdir -p /workspace /data /root/.ssh /var/run/sshd /var/log/supervisor /var/log/nginx /data/db && \
    chmod 700 /root/.ssh && \
    rm -f /etc/nginx/sites-enabled/* /etc/nginx/sites-available/* && \
    chown www-data /var/log/nginx && \
    echo "alias ctl='supervisorctl -c /etc/supervisor/supervisord.conf'" >> /root/.bashrc
    
ADD nginx.conf /etc/nginx/
ADD supervisor /etc/supervisor/

RUN sed -i 's/PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

RUN npm install -g \
    node-gyp \
    fibers \
    yo \
    forever \
    bower \
    coffee \
    grunt-cli \
    gulp \
    less \
    saas \
    typescript \
    stylus \
    iron-meteor \
    demeteorizer \
    node-inspector

RUN git clone https://github.com/c9/core.git /c9 && \
    cd /c9 && \
    sed -i 's/https:\/\/raw.githubusercontent.com\/c9\/install/https:\/\/raw.githubusercontent.com\/srault95\/install/' ./scripts/install-sdk.sh && \
    ./scripts/install-sdk.sh && \
    sed -i -e 's/127.0.0.1/0.0.0.0/g' /c9/configs/standalone.js 

RUN curl https://install.meteor.com/ |sh

ADD gen-ssl.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/gen-ssl.sh

ADD start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

VOLUME /home/persist/git/repos
VOLUME /etc/nginx/virtual
VOLUME /workspace

WORKDIR /workspace

EXPOSE 443
EXPOSE 444

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/usr/local/bin/start.sh"]

