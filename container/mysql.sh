#!/bin/sh
exec /sbin/setuser mysql /usr/sbin/mysqld >> /var/log/mysql.log 2>&1
