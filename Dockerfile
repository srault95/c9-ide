#FROM node:latest
#FROM node:slim
FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive
ENV BIND_IP 0.0.0.0
ENV PORT 8099
ENV NODE_VERSION 0.12.4
ENV NPM_VERSION 2.11.0
#ENV DISABLE_WEBSOCKETS 1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bzip2 \
    sudo \
    build-essential \
    rsyslog \
    openssh-server \
    supervisor \
    git \
    ca-certificates \
    curl \
    python \
    chrpath libfreetype6 libfreetype6-dev libssl-dev libfontconfig1 imagemagick
    
RUN curl -SLO http://nodejs.org/dist/latest/node-v$NODE_VERSION-linux-x64.tar.gz && \
    tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 && \
    rm "node-v$NODE_VERSION-linux-x64.tar.gz" && \
    npm install -g npm@"$NPM_VERSION" && \
    npm cache clear

#RUN mkdir -p /var/www
#RUN chown -R www-data:www-data /var/www

RUN npm install -g forever phantomjs fibers bower grunt-cli gulp iron-meteor

RUN echo "PS1='(container)\u@\h:\w\$ '" >> /root/.bashrc

RUN mkdir -p /var/run/sshd /var/log/supervisor
ADD supervisord.conf /etc/supervisor/

RUN sed -i 's/PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

#sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

RUN curl https://install.meteor.com/ |sh

ADD start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

VOLUME /home/persist/git/repos
VOLUME /projects
WORKDIR /projects

EXPOSE 8099

CMD ["/usr/local/bin/start.sh"]

