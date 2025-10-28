#!/bin/bash
set -e

echo "Installing gems..."
bundle install

echo "Waiting for MySQL..."
until mysqladmin ping -h"$BUCKY_DB_HOSTNAME" -u"$BUCKY_DB_USERNAME" -p"$BUCKY_DB_PASSWORD" --silent; do
  echo "MySQL is unavailable - sleeping"
  sleep 2
done

echo "MySQL is up - executing command"
exec "$@"
