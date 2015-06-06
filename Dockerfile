FROM node:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bzip2 \
    sudo \
    build-essential \
    rsyslog \
    openssh-server \
    supervisor \
    git \
    curl \
    python

RUN mkdir -p /var/www
RUN chown -R www-data:www-data /var/www

#RUN npm install -g fibers

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

CMD ["/usr/local/bin/start.sh"]

