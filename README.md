# Builder

Liftopia's build server slaves for jenkins, including everything we need to pretend like a server.

## Whaaaa?

This is basically just an all encompassing docker image containing the known databases for our applications, including mysql, redis, and memcached. Future versions might be more configurable, but for now this is enough.

## Preparation

1. Build a 512MB host in Digital Ocean with Ubuntu 14.04 x64 and an SSH key.
2. Update and upgrade the system all the way:
```sh
apt-get update && \
apt-get dist-upgrade -y && \
update-grub && \
reboot
```
3. Clear out old packages for fun.
```sh
apt-get autoremove -y && \
update-grub && \
reboot
```
4. Enable swap.
```sh
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo /swapfile   none    swap    sw    0   0 >> /etc/fstab
```

## Installation
### Builds from Hub

1. Install Docker.
```sh
apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

cat > /etc/apt/sources.list.d/docker.list << EOF
deb https://apt.dockerproject.org/repo ubuntu-trusty main
EOF

apt-get update && \
apt-get install docker-engine -y
```
2. Create storage container.
```sh
docker create -v /bundles --name builder-storage liftopia/builder /bin/true
```
3. Create builder container.
```sh
docker create --name builder -p <inbound-port>:22 --volumes-from builder-storage builder
```
4. Start on boot and boot container.
```sh
cat > /etc/init/builder.conf << EOF
description "builder"

start on filesystem and started docker
stop on runlevel [!2345]
respawn

script
  /usr/bin/docker start -a builder
end script
EOF

start builder
```

### Manual Builds

1. Clone this repo to the server.
```sh
apt-get install git -y
git clone https://github.com/liftopia/builder.git
```
2. Bootstrap!
```sh
cd builder
./script/bootstrap
```
