#!/bin/sh

# Need to be set, otherwise X11 will not work
export QT_X11_NO_MITSHM=1

# Start MySQL if mysql hostnames is empty or localhost
if [ -z "$MYSQL_HOST" ] || [ "$MYSQL_HOST" == "localhost" ]; then

  if [ -d "/var/lib/mysql/mysql" ]; then
    echo "### Starting MySQL Server ###"
    /usr/sbin/mysqld &
  else
    echo "### /var/lib/mysql is empty, initializing ###"
    /usr/sbin/mysqld --initialize-insecure --basedir=/var/lib/mysql
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'domotiga';" >/tmp/mysql-init
    /usr/sbin/mysqld --init-file=/tmp/mysql-init &
  fi

  if [ ! -d "/var/lib/mysql/domotiga" ]; then
    echo "### Sleeping for 5 seconds, waiting on MySQL to be available ###"
    sleep 5

    if [ -e /var/run/mysqld/mysqld.sock ]; then
      echo "### Creating DomotiGa database ###"
      mysqladmin -u root -pdomotiga create domotiga
      mysql -h localhost -u root -pdomotiga domotiga </domotiga/install/domotiga.sql
    else
      echo "### Weird, MySQL is not running? ###"
    fi
  fi

fi

echo "#### Starting DomotiGa ###"
exec /domotiga/DomotiGa3.gambas -c config/domotiga.conf

