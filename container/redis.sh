#!/bin/sh
exec /sbin/setuser redis /usr/local/bin/redis-server /etc/redis/6379.conf >> /var/log/redis.log 2>&1
