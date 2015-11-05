FROM phusion/baseimage:0.9.17

CMD ["/sbin/my_init"]

RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install git memcached mysql-server-5.6 openjdk-6-jre-headless build-essential -y

RUN \
    cd /tmp && \
    curl http://download.redis.io/releases/redis-2.8.21.tar.gz -o /tmp/redis-2.8.21.tar.gz && \
    tar zxvf redis-2.8.21.tar.gz && \
    cd redis-2.8.21 && \
    make && \
    make install && \
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    \curl -sSL https://get.rvm.io | bash -s stable --ruby=2.2.2 --with-default-gems="bundler"

RUN \
    curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash - && \
    apt-get install nodejs -y && \
    npm install -g phantomjs@1.9.16

RUN \
    mkdir /etc/service/memcached && \
    mkdir /etc/service/redis && \
    mkdir /etc/service/mysql && \
    mkdir /etc/redis && \
    mkdir -p /data/bundles && \
    rm -f /etc/service/sshd/down && \
    /etc/my_init.d/00_regen_ssh_host_keys.sh && \
    useradd -m -s /bin/false redis && \
    useradd -m -s /bin/bash -p '*' jenkins && \
    usermod -G rvm -a jenkins

RUN \
    apt-get install libmysqlclient-dev libgmp-dev libfontconfig -y

RUN \
    bash -l -c "gem install napkin -v 0.0.5"

ADD container/memcached.sh /etc/service/memcached/run
ADD container/mysql.sh /etc/service/mysql/run
ADD container/redis.conf /etc/redis/6379.conf
ADD container/redis.sh /etc/service/redis/run
ADD container/authorized_keys /home/jenkins/.ssh/authorized_keys
ADD container/known_hosts /home/jenkins/.ssh/known_hosts
ADD container/rc.local /etc/rc.local

EXPOSE 22
VOLUME ["/data"]

RUN \
    chown -R jenkins.jenkins /home/jenkins /data

RUN \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
