#!/bin/bash -e

# basic packages
PACKAGES="git memcached mysql-server-5.6 openjdk-6-jre-headless build-essential \
          libmysqlclient-dev libgmp-dev libfontconfig python-pip nodejs"
curl -sL https://deb.nodesource.com/setup_0.12 | bash -
apt-get update
apt-get upgrade -y
apt-get install $PACKAGES -y

# memcached setup
mkdir /etc/service/memcached
ln -snfT /builder/memcached.sh /etc/service/memcached/run

# mysql setup
mkdir /etc/service/mysql
ln -snfT /builder/mysql.sh /etc/service/mysql/run

# redis 2.8.21
REDIS_VERSION=${REDIS_VERSION:-"2.8.21"}
cd /tmp
curl http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz -o /tmp/redis-$REDIS_VERSION.tar.gz
tar zxvf redis-$REDIS_VERSION.tar.gz
cd redis-$REDIS_VERSION
make
make install
useradd -m -s /bin/false redis
mkdir /etc/redis
ln -snfT /builder/redis.conf /etc/redis/6379.conf
mkdir /etc/service/redis
ln -snfT /builder/redis.sh /etc/service/redis/run

# rvm and ruby 2.2.2
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --ruby=2.2.2 --with-default-gems="bundler napkin=~>0.0.5"
echo "gem: --no-rdoc --no-ri" >> /etc/gemrc

# tooling
npm install -g phantomjs@1.9.16
pip install awscli

# ssh configuration
rm -f /etc/service/sshd/down
/etc/my_init.d/00_regen_ssh_host_keys.sh

# set up jenkins slave living spaces
useradd -m -s /bin/bash -p '*' jenkins
usermod -G rvm -a jenkins
mkdir -p /data/bundles /home/jenkins/.ssh
ln -snfT /builder/authorized_keys /home/jenkins/.ssh/authorized_keys
ln -snfT /builder/known_hosts /home/jenkins/.ssh/known_hosts
chown -R jenkins.jenkins /home/jenkins

# final cleanup
ln -snfT /builder/rc.local /etc/rc.local
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
