# Builder

Liftopia's build server slaves for jenkins, including everything we need to pretend like a server.

## Whaaaa?

This is basically just an all encompassing docker image containing the known databases for our applications, including mysql, redis, and memcached. Future versions might be more configurable, but for now this is enough.

## Installation

1. Build a 512MB host in Digital Ocean with Ubuntu 14.04 x64 and an SSH key.
2. Update and upgrade the system all the way, installing git for good measure (unless you picked this up from a tarball):
```sh
apt-get update
apt-get dist-upgrade -y
apt-get install git -y
update-grub
reboot
```
3. Clear out old packages for fun.
```sh
apt-get autoremove -y
update-grub
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
5. Clone this repo to the server.
```sh
git clone https://github.com/liftopia/builder.git
```
6. Bootstrap!
```sh
cd builder
./script/bootstrap
```
