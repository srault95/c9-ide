#FROM node:latest
#FROM node:slim
FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:chris-lea/node.js && \
    apt-get update

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
    nodejs

RUN mkdir -p /var/www
RUN chown -R www-data:www-data /var/www

RUN npm install --silent -g forever phantomjs fibers

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

CMD ["/usr/local/bin/start.sh"]

